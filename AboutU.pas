unit AboutU;
   (* 
   WorldVistA Configuration Utility
   (c) 8/2008 Kevin Toppenberg
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
  Dialogs, StdCtrls, jpeg, ExtCtrls, Math;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FadeIn : boolean;
    FInitialSysTime : Int64;
    function ElapsedSysTime : Extended; //returns in milliseconds;
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses MainU;

{$R *.dfm}

  const MIN_ALPHA = 50;
       TIMER_SPEED = 1;

  procedure TAboutForm.FormClick(Sender: TObject);
  begin
    QueryPerformanceCounter(FInitialSysTime);
    Timer1.Enabled := true;
    FadeIn := false;
    Timer1.Interval := TIMER_SPEED;
    AboutForm.AlphaBlendValue := 255;
  end;

  procedure TAboutForm.Timer1Timer(Sender: TObject);
  var i : integer;
      Pct : integer;  //will be 0-255 (255=100%)
  const delta = 5;
        TIME_FOR_FADE = 1000;  //milliseconds
  begin
    Pct := Floor((ElapsedSysTime / TIME_FOR_FADE) * 255);
    if Pct>255 then Pct := 255;
    if FadeIn then begin
      if AboutForm.AlphaBlendValue < 255 then begin
        {
        i := AboutForm.AlphaBlendValue;
        i := i +delta;
        if i > 255 then begin
          i := 255;
          Timer1.Enabled := false;
        end;
        AboutForm.AlphaBlendValue := i;
        }
        AboutForm.AlphaBlendValue := Pct;
      end else begin
        Timer1.Enabled := false;
      end;
    end else begin
      if AboutForm.AlphaBlendValue > MIN_ALPHA then begin
        AboutForm.AlphaBlendValue := 255-Pct;
        {
        i := AboutForm.AlphaBlendValue;
        i := i - delta;
        if i < MIN_ALPHA then i := MIN_ALPHA;
        AboutForm.AlphaBlendValue := i;
        }
      end else begin
        Timer1.Enabled := false;
        MainForm.Show;
        Close;
      end;
    end;
  end;

  procedure TAboutForm.FormShow(Sender: TObject);
  var  FileName : string;
  begin
    QueryPerformanceCounter(FInitialSysTime);
    FileName := ExtractFilePath(ParamStr(0))+ 'splash.jpg';
    if FileExists(FileName) then begin
      Image1.Picture.LoadFromFile(FileName);
    end;
    Image1.Width := Image1.Picture.Width;
    Image1.Height := Image1.Picture.Height;
    Self.Width := Image1.Picture.Width;
    Self.Height := Image1.Picture.Height + Memo1.Height + 35;  //not sure why 35 extra needed...
    Self.Left:=(Screen.Width - Self.Width) div 2;
    Self.Top := (Screen.Height - Self.Height) div 2;
    MainForm.Hide;

    Timer1.Enabled := true;
    FadeIn := true;
    Timer1.Interval := TIMER_SPEED;
    AboutForm.AlphaBlendValue := MIN_ALPHA;
  end;

  function TAboutForm.ElapsedSysTime : Extended; //returns in milliseconds;
  var
    CurSysTime, FreqPerSec: Int64;
  begin
    QueryPerformanceFrequency(FreqPerSec);
    QueryPerformanceCounter(CurSysTime);
    Result := ((CurSysTime - FInitialSysTime) / FreqPerSec) * 1000;
    //if Result > 100 then Result := 1; //prevent problems after big delay
  end;



end.

