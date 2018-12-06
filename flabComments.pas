unit flabComments;
   (*
   WorldVistA Configuration Utility
   (c) 9/2013 Kevin Toppenberg
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
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmLabComments = class(TForm)
    pnlBottom: TPanel;
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    memComments: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  frmLabComments: TfrmLabComments;

implementation

{$R *.dfm}

end.
