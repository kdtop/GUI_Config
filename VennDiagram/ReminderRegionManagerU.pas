unit ReminderRegionManagerU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Math,
  Dialogs, ExtCtrls, EllipseObject, TMGGraphUtil, Forms, StrUtils,
  VennObject, StdCtrls, ComCtrls,  Pointf, Rectf, ColorUtil,
  ReminderObjU, RegionManager, TypesU;

type

  TRemRgnManager = class (TRgnManager)
  private
    function GetSelRemObject : TRemObj;
    procedure SetSelRemObject (Value : TRemObj);
    function GetOnSelChange : TNotifyRemObjectEvent;
    procedure SetOnSelChange (Value : TNotifyRemObjectEvent);
    function GetOnRtClickRemObject : TNotifyRemObjectEvent;
    procedure SetOnRtClickRemObject (Value : TNotifyRemObjectEvent);
    function GetOnDblClickRemObject : TNotifyRemObjectEvent;
    procedure SetOnDblClickRemObject (Value : TNotifyRemObjectEvent);
  public
    constructor Create(AParent : TWinControl);
    destructor Destroy; override;
    function NewChild (Parent : TRemObj = nil) : TRemObj;
    //property Canvas;
    //property ZoomStack;
    //property WallpaperBM;
    //property OnRefreshNeeded;
    property OnSelChange : TNotifyRemObjectEvent read GetOnSelChange write SetOnSelChange;
    property OnRtClickRemObject : TNotifyRemObjectEvent read GetOnRtClickRemObject write SetOnRtClickRemObject;
    property OnDblClickRemObject : TNotifyRemObjectEvent read GetOnDblClickRemObject write SetOnDblClickRemObject;
    property SelRemObject : TRemObj read GetSelRemObject write SetSelRemObject;
  end;


implementation
  constructor TRemRgnManager.Create(AParent : TWinControl);
  begin
    Inherited Create(AParent);
    //
  end;

  destructor TRemRgnManager.Destroy;
  begin
    //
    Inherited Destroy;
  end;

  function TRemRgnManager.NewChild (Parent : TRemObj = nil) : TRemObj;
  //Note: all creation of children should be done HERE.
  var RemObject : TRemObj;
  begin
    RemObject := TRemObj.Create(Parent);
    Result := RemObject;
    InitNewChild(RemObject);
    AddObj(RemObject); //This will own objects.
  end;

  function TRemRgnManager.GetSelRemObject : TRemObj;
  begin
    Result := TRemObj(FSelVennObject);
  end;

  procedure TRemRgnManager.SetSelRemObject (Value : TRemObj);
  begin
    SetSelVennObject(Value);
  end;

  function TRemRgnManager.GetOnSelChange : TNotifyRemObjectEvent;
  begin
    Result := TNotifyRemObjectEvent(FOnSelChange);
  end;

  procedure TRemRgnManager.SetOnSelChange (Value : TNotifyRemObjectEvent);
  begin
    FOnSelChange := TNotifyForVennObjectEvent(Value);
  end;

  function TRemRgnManager.GetOnRtClickRemObject : TNotifyRemObjectEvent;
  begin
    Result := TNotifyRemObjectEvent(FOnRtClickVennObject);
  end;

  procedure TRemRgnManager.SetOnRtClickRemObject (Value : TNotifyRemObjectEvent);
  begin
    FOnRtClickVennObject := TNotifyForVennObjectEvent(Value);
  end;

  function TRemRgnManager.GetOnDblClickRemObject : TNotifyRemObjectEvent;
  begin
    Result := TNotifyRemObjectEvent(FOnDblClickVennObject);
  end;

  procedure TRemRgnManager.SetOnDblClickRemObject (Value : TNotifyRemObjectEvent);
  begin
    FOnDblClickVennObject := TNotifyForVennObjectEvent(Value);
  end;

end.
