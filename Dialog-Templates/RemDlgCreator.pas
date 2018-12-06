unit RemDlgCreator;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls,
  Dialogs, StdCtrls, StrUtils, ORNet, ORFn;

type
  TVirtDlgChildReq = (crNone, crOne, crAtLeastOne, crNoneOrOne, crAll);
  TVirtDlgElemType = (etCheckBox, etTaxonomy, etDisplayOnly);
  TVirtDlgElemResult = (vdtNone,
                        vdtDiagnosis,
                        vdtProcedure,
                        vdtPatientEducation,
                        vdtExam,
                        vdtHealthFactor,
                        vdtImmunization,
                        vdtSkinTest,
                        vdtVitals,
                        vdtOrder,
                        vdtMentalHealthTest,
                        vdtWHPapResult,
                        vdtWHNotPurp);

  //----------------------------------------------------------------------
  //NOTE:
  //  This object will be writen such that one node should contain all
  //  other nodes.  Thus first create one element as follows:
  //     RootNode := TVirtDlgElement.Create(nil);
  //  Then, all subsequent children should be created as follows:
  //     AChild := RootNode.CreateChild;    -or-
  //     AChild.CreateChild;
  //  The root should not contain any output information.  It will simply
  //     hold the top level visible objects.
  //  To delete the entire tree, just do Root.Free;
  //  To get output text, do Root.OutputDefToSL(sl);
  //  To get result text for one of the nodes anywere in the definition tree,
  //     do Root.OutputResultsToSL(<ID Of Desired Element>, sl)

  TVirtDlgElement = class (TObject)
  private
    FLastUsedUniqueID : integer; //only used if FParent = nil;
    FUniqueID : Integer;
    FLastUsedSubNum : integer;
    FText : TStringList;
  protected
    FChildList : TList;  //This list owns children.
    FParent : TVirtDlgElement;
    SubID : string;                                    //piece #3
    function GetChild(Index : Integer) : TVirtDlgElement;
    function GetNextUniqueID : integer;
    function GetNextSubNum : integer;
    procedure Add(var s : string; PieceNum : integer; Value : string);
  public
    ElementType : TVirtDlgElemType;                    //piece #4
    ExcludeFromProgressNote : boolean;                 //piece #5
    IndentNum : integer;                               //piece #6
    FindingTypeCode : string;                          //piece #7
    Historical : boolean;                              //piece #8
    ExcludeMHTestFromProgressNote : boolean;           //piece #9
    ResultGroup : string;                              //piece #10
    HideUntilChecked : boolean;                        //piece #15
    ChildrenIndentNum : integer;                       //piece #16
    ShareCommonPrompt : boolean;                       //piece #17
    AnswersType: TVirtDlgChildReq;                     //piece #18
    DrawBox : boolean;                                 //piece #19
    Caption : string;                                  //piece #20
    IndentProgressNoteText : boolean;                  //piece #21

    //Result Info
    ResultType : TVirtDlgElemResult;
    ResultIEN : string;
    ResultDisplayName : string;
    ResultCat : string;
    ResultPce11Code : string;    //can start with 'D', 'Q', 'M', 'O', 'A'
    ResultAlternativePNText : string;

    //procedure InsertChild (AChild : TVirtDlgElement);
    procedure DelChild (AChild : TVirtDlgElement); overload;
    procedure DelChild (Index : integer); overload;
    function ChildCount : integer;
    function CreateChild : TVirtDlgElement;
    function IsRoot : boolean;  //true if this object has no parent.
    procedure OutputDefToSL(SL : TStrings);
    function OutputResultsToSL(ID : integer; SL : TStrings) : boolean;
    procedure Clear();
    constructor Create(AParent : TVirtDlgElement);
    destructor Destroy;
    property Child[Index : integer] : TVirtDlgElement read GetChild;
    property UniqueID : integer read FUniqueID;
    property Text : TStringList read FText;
  end;

const
  BOOL2CHAR : array[false .. true] of char = ('0','1');
  ANSWERS_TYPE : array[crNone .. crAll] of char = ('0','1','2','3','4');
  ELEMENT_TYPE : array[etCheckBox .. etDisplayOnly] of char = ('S','T','D');

  RESULT_CODE : array[vdtNone .. vdtWHNotPurp] of string[8] =
                  { vdtNone            } ('',
                  { dtDiagnosis        }  'POV',
                  { dtProcedure        }  'CPT',
                  { dtPatientEducation }  'PED',
                  { dtExam             }  'XAM',
                  { dtHealthFactor     }  'HF',
                  { dtImmunization     }  'IMM',
                  { dtSkinTest         }  'SK',
                  { dtVitals           }  'VIT',
                  { dtOrder            }  'Q',
                  { dtMentalHealthTest }  'MH',
                  { dtWHPapResult      }  'WHR',
                  { dtWHNotPurp        }  'WH');



implementation

  constructor TVirtDlgElement.Create(AParent : TVirtDlgElement);
  begin
    Inherited Create;
    FLastUsedUniqueID := 0;
    FLastUsedSubNum := 0;
    FParent := AParent;
    FChildList := TList.Create;
    FText := TStringList.Create;

    SubID :='1'; //overwritten if not root             //piece #3
    ElementType := etCheckBox;                         //piece #4
    ExcludeFromProgressNote := false;                  //piece #5
    IndentNum := 0;                                    //piece #6
    FindingTypeCode := '';                             //piece #7
    Historical := false;                               //piece #8
    ExcludeMHTestFromProgressNote := false;            //piece #9
    ResultGroup :='';                                  //piece #10
    HideUntilChecked := true;                          //piece #15
    ChildrenIndentNum := 0;                            //piece #16
    ShareCommonPrompt := false;                        //piece #17
    AnswersType := crNone;                             //piece #18
    DrawBox := false;                                  //piece #19
    Caption := '';                                     //piece #20
    IndentProgressNoteText := true;                    //piece #21

    ResultType := vdtNone;
    ResultIEN := '';
    ResultDisplayName := '';
    ResultCat := '';
    ResultPce11Code := '';
    ResultAlternativePNText := '';
  end;

  destructor TVirtDlgElement.Destroy;
  begin
    Clear;
    FChildList.Free;
    FText.Free;
    inherited Destroy;
  end;

  procedure TVirtDlgElement.Clear();
  var
    i : integer;
    AChild : TVirtDlgElement;
  begin
    for i := 0 to FChildList.Count -1 do begin
      AChild := TVirtDlgElement(FChildList.Items[i]);
      AChild.Free;
    end;
  end ;
  {
  procedure TVirtDlgElement.InsertChild (AChild : TVirtDlgElement);
  begin
    if not assigned(AChild) then exit;
    if FChildList.IndexOf(AChild) < 0 then begin
      FChildList.Add(AChild);
    end;
  end;
  }

  procedure TVirtDlgElement.DelChild (AChild : TVirtDlgElement);
  var i : integer;
  begin
    i := FChildList.IndexOf(AChild);
    if i < 0 then exit;
    FreeAndNil(AChild);
    FChildList.Delete(i);
  end;

  procedure TVirtDlgElement.DelChild (Index : integer);
  var AChild : TVirtDlgElement;
  begin
    AChild := GetChild(Index);
    if not assigned(AChild) then exit;
    AChild.Free;
    FChildList.Delete(Index);
  end;

  function TVirtDlgElement.GetChild(Index : Integer) : TVirtDlgElement;
  var i : integer;
  begin
    Result := nil;
    if (Index < 0) or (Index >= FChildList.Count) then exit;
    Result := TVirtDlgElement(FChildList.Items[Index]);
  end;

  function TVirtDlgElement.ChildCount : integer;
  begin
    Result := FChildList.Count;
  end;

  function TVirtDlgElement.GetNextUniqueID : integer;
  begin
    if IsRoot then begin
      Inc(FLastUsedUniqueID);
      Result := FLastUsedUniqueID;
    end else begin
      Result := FParent.GetNextUniqueID;
    end;
  end;

  function TVirtDlgElement.GetNextSubNum : integer;
  begin
    inc(FLastUsedSubNum);
    Result := FLastUsedSubNum;
  end;


  function TVirtDlgElement.CreateChild : TVirtDlgElement;
  var ChildSubID : string;
  begin
    Result := TVirtDlgElement.Create(Self);
    Result.FUniqueID := Self.GetNextUniqueID;
    ChildSubID := Self.SubID;
    if ChildSubID <> '' then ChildSubID := ChildSubID + '.';
    ChildSubID := ChildSubID + IntToStr(GetNextSubNum);
    FChildList.Add(Result);
    Result.SubID := ChildSubID;
  end;

  function TVirtDlgElement.IsRoot : boolean;
  //true if this object has no parent.
  begin
    Result := (FParent = nil);
  end;

  procedure TVirtDlgElement.Add(var s : string; PieceNum : integer; Value : string);
  begin
    Value := StringReplace(Value,'^','/\', [rfReplaceAll]);  //can't allow delimiter in string
    SetPiece(s, '^', PieceNum, Value);
  end;


  procedure TVirtDlgElement.OutputDefToSL(SL : TStrings);
  var s : string;
      i : integer;

  begin
    if IsRoot then begin
      SL.Clear;
      SL.Add('0^1');  //1 = RemWipe=true;
    end else begin
      //Output #1 type node
      Add(s, 1,  '1');
      Add(s, 2,  IntToStr(UniqueID));
      Add(s, 3,  SubID);
      Add(s, 4,  ELEMENT_TYPE[ElementType]);
      Add(s, 5,  BOOL2Char[ExcludeFromProgressNote]);
      Add(s, 6,  IntToStr(IndentNum));
      Add(s, 7,  FindingTypeCode);
      Add(s, 8,  BOOL2Char[Historical]);
      Add(s, 9,  BOOL2Char[ExcludeMHTestFromProgressNote]);
      Add(s, 10, ResultGroup);
      Add(s, 15, BOOL2Char[HideUntilChecked]);
      Add(s, 16, IntToStr(ChildrenIndentNum));
      Add(s, 17, BOOL2Char[ShareCommonPrompt]);
      Add(s, 18, ANSWERS_TYPE[AnswersType]);
      Add(s, 19, BOOL2Char[DrawBox]);
      Add(s, 20, Caption);
      Add(s, 21, BOOL2Char[IndentProgressNoteText]);
      SL.Add(s); s := '';

      //Output #2 node (if indicated)
      for i := 0 to FText.Count-1 do begin
        Add(s, 1, '2');
        Add(s, 2, IntToStr(UniqueID));
        Add(s, 3, SubID);
        Add(s, 4, FText.Strings[i]);
        SL.Add(s); s := '';
      end;
    end;

    //Now add children's output
    for i := 0 to FChildList.Count-1 do begin
      GetChild(i).OutputDefToSL(SL);
    end;
  end;


  function TVirtDlgElement.OutputResultsToSL(ID : integer; SL : TStrings) : boolean;
  //Results : true if match found between ID and Self.UniqueID
  var s : string;
      i : integer;

  begin
    Result := false;
    SL.Clear;
    if ID = UniqueID then begin
      Result := true;
      if ResultType = vdtNone then exit;  //return emptry StringList.

      //Output #3 type node
      Add(s, 1, '3');
      Add(s, 2, IntToStr(UniqueID));
      Add(s, 4, RESULT_CODE[ResultType]);
      Add(s, 6, ResultIEN);
      Add(s, 8, ResultDisplayName);
      Add(s, 9, ResultCat);
      Add(s, 11,ResultPce11Code);
      SL.Add(s); s := '';

      //Output #6 type node, if indicated
      if ResultAlternativePNText <> '' then begin
        Add(s, 1, '6');
        Add(s, 2, IntToStr(UniqueID));
        Add(s, 4, ResultAlternativePNText);
        SL.Add(s); s := '';
      end;
    end else begin
      for i := 0 to FChildList.Count - 1 do begin
        Result := GetChild(i).OutputResultsToSL(ID,SL);
        if Result then break;
      end;
    end;
  end;


end.

