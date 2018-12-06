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
procedure GetAlertData(AlertData : TStringList; WhichOne : string);
function Process(Messages : TStringList; WhichOne : string) : string;


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

procedure GetAlertData(AlertData : TStringList; WhichOne : string);
var  RPCResult : string;
begin
  AlertData.Clear;
  PrepRPC('GET ONE HL7 ALERT INFO', [WhichOne]);
  if CallBrokerAndErrorCheck(RPCResult) then begin
    AlertData.Assign(RPCBrokerV.Results);
  end;
end;

function Process(Messages : TStringList; WhichOne : string) : string;
var  RPCResult : string;
     NumResult : string;
begin
  Result := '';
  Messages.Clear;
  PrepRPC('PROCESS', [WhichOne+'^1']);
  LastHL7RPCHadError := false;
  RPCBrokerV.Results.Clear;
  CallBroker;
  RPCResult := RPCBrokerV.Results[0];    //returns:  error: -1;  success=1
  NumResult := piece(RPCResult,'^',1);
  Result := pieces(RPCResult,'^',2,NumPieces(RPCResult,'^'));
  RPCBrokerV.Results.Delete(0);
  Messages.Assign(RPCBrokerV.Results);
  if NumResult = '-1' then begin
    //FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
    //FMErrorForm.Memo.Lines.Insert(0,Result);
    //FMErrorForm.PrepMessage;
    //FMErrorForm.ShowModal;
  end;
end;



end.
