unit ReminderObjU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, Math, EllipseObject, StrUtils, TMGStrUtils,
  TMGGraphUtil, ColorUtil, Pointf, Rectf, TypesU, VennObject;

type
  TRemObj = class;
  TNotifyRemObjActionRequestEvent = procedure (Obj : TRemObj; var Allowed : boolean);
  TNotifyRemObjectEvent = procedure(Obj: TRemObj) of object;
  TRemObj = class(TVennObj)
    Protected
      function GetOnDeleteRequest : TNotifyRemObjActionRequestEvent;
      procedure SetOnDeleteRequest (Value : TNotifyRemObjActionRequestEvent);
      function GetObjColorForMouse(MousePos : TPoint) : TColor; override;
    public
      GridInfo : TCompleteGridInfo;
      OwnsGridInfo : boolean;  //if true, then GridInfo will be free'd when this object is destroyed
      constructor Create(Parent : TRemObj);
      destructor Destroy; override;
      property OnDeleteRequest : TNotifyRemObjActionRequestEvent read GetOnDeleteRequest write SetOnDeleteRequest;
    published
  end;


implementation

  uses ReminderRegionManagerU;

  function RgnMgr(Obj : TVennObj) : TRemRgnManager;
  begin Result := TRemRgnManager(Obj.RgnManager); end;

  constructor TRemObj.Create(Parent : TRemObj);
  begin
    Inherited Create(Parent);
    OwnsGridInfo := false;
    //
  end;

  destructor TRemObj.Destroy;
  begin
    //
    //NOTE: This is not getting called when Inherited deletes it's children, because Inherited
    //      thinks children are of type TVennObj not TRemObj.. FIX...
    if OwnsGridInfo then FreeAndNil(GridInfo);
    Inherited Destroy;
  end;

  function TRemObj.GetObjColorForMouse(MousePos : TPoint) : TColor;
  begin
    Result := Inherited GetObjColorForMouse(MousePos);
  end;


  function TRemObj.GetOnDeleteRequest : TNotifyRemObjActionRequestEvent;
  begin Result := TNotifyRemObjActionRequestEvent(FOnDeleteRequest); end;

  procedure TRemObj.SetOnDeleteRequest (Value : TNotifyRemObjActionRequestEvent);
  begin FOnDeleteRequest := TNotifyVennObjActionRequestEvent(Value); end;

end.
