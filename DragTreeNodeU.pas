unit DragTreeNodeU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, ComCtrls, Forms,
  Dialogs, StdCtrls, StrUtils;

type
  TDragTreeNode = class(TDragObjectEx)
    private
      FDragImages : TDragImageList;
    public
      TreeNode : TTreeNode;
      function GetDragCursor(Accepted : boolean; X, Y : Integer) : TCursor; override;
      function GetDragImages : TDragImageList; override;
      constructor Create;
      destructor Destroy;
  end;


implementation

  //----------------------------

  function TDragTreeNode.GetDragCursor(Accepted : boolean; X, Y : Integer) : TCursor;
  begin
    Result := inherited GetDragCursor(Accepted, X, Y);
  end;

  function TDragTreeNode.GetDragImages : TDragImageList;
  var
    Size : TSize;
    DragCursorBM : TBitmap;
    BMIndex : integer;
    ANode : TTreeNode;
    s : string;

  begin
    Result := FDragImages;
    ANode := Self.TreeNode;  //test ANode for nil?
    DragCursorBM := TBitmap.Create;
    try
      DragCursorBM.Canvas.Font.Name := 'Arial';
      DragCursorBM.Canvas.Font.Style := DragCursorBM.Canvas.Font.Style + [fsBold];
      s := '       ' + ANode.Text;
      Size := DragCursorBM.Canvas.TextExtent(s);

      DragCursorBM.Width := Size.cx;
      DragCursorBM.Height := Size.cy;
      DragCursorBM.Canvas.Brush.Color := clYellow; //clOlive;
      DragCursorBM.Canvas.FloodFill(0,0, clWhite, fsSurface);

      DragCursorBM.Canvas.TextOut(0, 0, s);
      Result.Width := DragCursorBM.Width;
      Result.Height := DragCursorBM.Height;
      BMIndex := Result.AddMasked(DragCursorBM, clOlive);
    finally
      DragCursorBM.Free;
    end;
  end;

  constructor TDragTreeNode.Create;
  begin
    inherited Create;
    FDragImages := TDragImageList.Create(nil);
  end;

  destructor TDragTreeNode.Destroy;
  begin
    FDragImages.Free;
    Inherited Destroy;
  end;


end.
