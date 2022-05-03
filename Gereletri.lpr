program Gereletri;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, printer4lazarus, dbflaz, U_Main, zcomponent, u_splash, u_gera_barcode;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  SplashScreen:= TSplashScreen.create(application);
  SplashScreen.show;
  SplashScreen.Update;
  application.ProcessMessages; // to be sure to show the splash
  Application.CreateForm(TW_Main, W_Main);
  //Application.CreateForm(TSplashScreen, SplashScreen);
  SplashScreen.close;
  SplashScreen.Release;
  Application.CreateForm(TW_GenerateBarCode, W_GenerateBarCode);
  Application.Run;
end.

