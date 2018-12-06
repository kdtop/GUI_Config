unit rHL7RPCsU;

   (*
   WorldVistA Configuration Utility
   (c) 2/2013 Kevin Toppenberg
   Programmed by Kevin Toppenberg, Eddie Hagood

   Family Physicians of Greeneville, PC
   1410 Tusculum Blvd, Suite 2600
   Greeneville, TN 37745
   kdtop@yahoo.com

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
  *)


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, StrUtils, ComCtrls, TypesU,
  ORNet, ORFn, Trpcb, FMErrorU;

var
  LastHL7RPCHadError : boolean;

procedure GetAvailAlertsList(AvailAlerts : TStringList);
procedure GetAlertData(AlertData : TStringList; AlertHandle : string);
function  ProcessHL7(ServerMessages : TStringList; AlertHandle : string; CumulativeClientServerMessages : TStringList) : string;
function ResolveHL7Error(AlertHandle : string) : integer;  //returns mrResult type
procedure SearchRecs(FileNum : string; Terms : string; Results : TStringList; ServerCustomizerFn : string);
function  AutoAddDataName(DataName : string) : string;
function  AddLabTest60(AlertHandle, TestName,PrintName, StorageLoc63d04 : string) : string;
function  NextAvailWorkLoadCode(WorkLoadCode : string) : string;
function  AddWorkLoadCode(Name, Code : string) : string;
function  GetIEN62FromIEN61(IEN61 : string) : string;
function  Link60ToDataName(AlertHandle, IEN60, StorageLoc63d04 : string) : string;


implementation

uses
  MainU;

  function CallBrokerAndErrorCheck(var RPCResult : string) : boolean;
  //NOTE: the RPC call must be set up prior to call this function.
  //Result of this function: true  if all OK, or false if error.
  //Also RPCResult is OUT parameter of the RPCBrokerV.Results[0] value
  //ALSO LastHL7RPCHadError variable (global scope) is set to error state call.
  //Results of RPC Call itself will be in RPCBrokerV
  begin
    LastHL7RPCHadError := false;
    Result := true;
    RPCBrokerV.Results.Clear;
    CallBroker;
    RPCResult := RPCBrokerV.Results[0];    //returns:  error: -1;  success=1
    RPCBrokerV.Results.Delete(0);
    if piece(RPCResult,'^',1)='-1' then begin
      LastHL7RPCHadError := true;
      Result := false;
      if RPCBrokerV.Results.Count = 0 then RPCBrokerV.Results.Add(RPCResult);
      FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
      FMErrorForm.Memo.Lines.Insert(0,MidStr(RPCResult,4,999));
      FMErrorForm.PrepMessage;
      FMErrorForm.ShowModal;
    end;
  end;

  procedure PrepRPC(FnName : string; StrArgs : Array of string);
  var cmd : string;
      i : integer;
  begin
    RPCBrokerV.remoteprocedure := 'TMG CHANNEL FOR HL7';
    RPCBrokerV.Param[0].Value := '.X';  // not used
    RPCBrokerV.param[0].ptype := list;
    cmd := FnName;
    for i := 0 to High(StrArgs) do begin
      if cmd <> '' then cmd := cmd + '^';
      cmd := cmd + StrArgs[i];

    end;
    RPCBrokerV.Param[0].Mult['"REQUEST"'] := cmd;
  end;


  procedure GetAvailAlertsList(AvailAlerts : TStringList);
  var  RPCResult : string;
  begin
    AvailAlerts.Clear;
    PrepRPC('LIST AVAIL HL7 ALERTS', []);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      AvailAlerts.Assign(RPCBrokerV.Results);
    end;
  end;

  procedure GetAlertData(AlertData : TStringList; AlertHandle : string);
  var  RPCResult : string;
  begin
    AlertData.Clear;
    PrepRPC('GET ONE HL7 ALERT INFO', [AlertHandle]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      AlertData.Assign(RPCBrokerV.Results);
    end;
  end;

  function ProcessHL7(ServerMessages : TStringList; AlertHandle : string; CumulativeClientServerMessages : TStringList) : string;
  //Var AlertHandle is $H^JobNum (used to retrieve info from data stored for Alert)
  var  RPCResult : string;
       NumResult : string;
       i, Count : integer;
       Prob,Fix : string;
  begin
    Result := '';
    ServerMessages.Clear;
    PrepRPC('PROCESS', [AlertHandle+'^1']);
    i := 0; Count := 0;
    while i < CumulativeClientServerMessages.Count do begin
      Prob := CumulativeClientServerMessages.Strings[i];
      if i+1 >= CumulativeClientServerMessages.Count then break;
      Fix := CumulativeClientServerMessages.Strings[i+1];
      Fix := piece(Fix,'REPLY=',2);
      i := i + 2;
      RPCBrokerV.Param[0].Mult['"GUI;MSG;' + IntToStr(Count) + '"'] := Prob;
      RPCBrokerV.Param[0].Mult['"GUI;MSG;' + IntToStr(Count) + ';REPLY"'] := Fix;
      Inc (Count);
    end;
    LastHL7RPCHadError := false;
    RPCBrokerV.Results.Clear;
    CallBroker;
    RPCResult := RPCBrokerV.Results[0];    //returns:  error: -1;  success=1
    NumResult := piece(RPCResult,'^',1);
    Result := pieces(RPCResult,'^',2,NumPieces(RPCResult,'^'));
    RPCBrokerV.Results.Delete(0);
    ServerMessages.Assign(RPCBrokerV.Results);
    if NumResult = '-1' then begin
      //FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
      //FMErrorForm.Memo.Lines.Insert(0,Result);
      //FMErrorForm.PrepMessage;
      //FMErrorForm.ShowModal;
    end;
  end;

  function ResolveHL7Error(AlertHandle : string) : integer;
  //Var AlertHandle is $H^JobNum (used to retrieve info from data stored for Alert)
  //Result: mrAbort or mrYesToAll
  var  RPCResult : string;
       NumResult : string;
       i, Count : integer;
       Prob,Fix : string;
  begin
    Result := mrAbort;
    PrepRPC('RESOLVE', [AlertHandle]);
    LastHL7RPCHadError := false;
    RPCBrokerV.Results.Clear;
    CallBroker;                                                         
    RPCResult := RPCBrokerV.Results[0];    //returns:  error: -1;  success=1
    NumResult := piece(RPCResult,'^',1);
    RPCResult := pieces(RPCResult,'^',2,NumPieces(RPCResult,'^'));
    RPCBrokerV.Results.Delete(0);
    if NumResult = '-1' then begin
      FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
      FMErrorForm.Memo.Lines.Insert(0,RPCResult);
      FMErrorForm.PrepMessage;
      FMErrorForm.ShowModal;
    end else begin
      Result := mrYesToAll;
    end;
  end;

  procedure SearchRecs(FileNum : string; Terms : string; Results : TStringList; ServerCustomizerFn : string);
  //Format of output:  Results(#)=IEN^FileNum^.01Name
  var  RPCResult : string;
  begin
    Results.Clear;
    PrepRPC('SEARCH RECS', [FileNum, Terms, ServerCustomizerFn]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Results.Assign(RPCBrokerV.Results);
    end;
  end;

  function AutoAddDataName(DataName : string) : string;
  //A 'Data Name' is a field in file 64.03.
  //Result: -- FldNumAddedIn64.03^Name
  //        or '' if problem.  Error message first shown here if problem encountered .
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    PrepRPC('AUTOADD DATANAME', [DataName]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCBrokerV.Results[0]; //<-- this used to be index 1 of RPC results
    end;
  end;

  function AddLabTest60(AlertHandle, TestName,PrintName, StorageLoc63d04 : string) : string;
  //Input: AlertHandle -- $H^JobNum (used to retrieve info from data stored for Alert)
  //            (this is needed because used to setup required TMGENV on server side)
  //       TestName -- the test name to add
  //       PrintName -- 7 character abbreviated name of test
  //       StorageLoc63d04 -- field number in subfile 63.04 where data will be stored.
  //Returns IEN60^Name, or '' if there is a problem.
  //       If -1^Message encountered, will be displayed here
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    AlertHandle := StringReplace(AlertHandle, '^', ';', [rfReplaceAll]);
    PrepRPC('ADD LAB 60', [AlertHandle, TestName,PrintName, StorageLoc63d04]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCBrokerV.Results[0]; //<-- this used to be index 1 of RPC results
    end;
  end;

  function NextAvailWorkLoadCode(WorkLoadCode : string) : string;
  //Input: WorkLoadCode  -- initial workload code that should be used as starting point for search for next available.
  //Returns NextAvailableWorkLodCode, or '' if there is a problem.
  //       If -1^Message encountered, will be displayed here
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    PrepRPC('NEXT AVAIL WKLD', [WorkLoadCode]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCBrokerV.Results[0]; //<-- this used to be index 1 of RPC results
    end;
  end;

  function AddWorkLoadCode(Name, Code : string) : string;
  //Returns IEN^WorkloadName^WorkloadCode, or '' if there is a problem.
  //       If -1^Message encountered, will be displayed here
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    PrepRPC('ADD WKLD', [Name, Code]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCBrokerV.Results[0]; //<-- this used to be index 1 of RPC results
    end;
  end;

  function GetIEN62FromIEN61(IEN61 : string) : string;
  //Returns IEN62, or '' if there is a problem.
  //       If -1^Message encountered, will be displayed here
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    PrepRPC('GET IEN62 FROM IEN61', [IEN61]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCBrokerV.Results[0]; //<-- this used to be index 1 of RPC results
      if Result='0' then Result := '';
    end;
  end;

  function Link60ToDataName(AlertHandle, IEN60, StorageLoc63d04 : string) : string;
  //Input: AlertHandle -- $H^JobNum (used to retrieve info from data stored for Alert)
  //            (this is needed because used to setup required TMGENV on server side)
  //       IEN60 -- the test to link
  //       StorageLoc63d04 -- field number in subfile 63.04 where data will be stored.
  //Returns 1^OK, or '' if there is a problem.
  //NOTE: DON'T RETURN -1^MESSAGE
  var  RPCResult : string;
  begin
    Result := '';
    AlertHandle := StringReplace(AlertHandle, '^', ';', [rfReplaceAll]);
    PrepRPC('LINK IEN60 TO DATANAME', [AlertHandle, IEN60, StorageLoc63d04]);
    if CallBrokerAndErrorCheck(RPCResult) then begin
      Result := RPCResult
    end;
  end;


end.
