unit u_splash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TSplashScreen }

  TSplashScreen = class(TForm)
    Panel1: TPanel;
  private

  public

  end;

var
  SplashScreen: TSplashScreen;

implementation

{$R *.lfm}

end.

