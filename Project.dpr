program Project;

uses
  Vcl.Forms,
  uFormDARFViewer in 'uFormDARFViewer.pas' {Form1},
  uPDFViewer in 'uPDFViewer.pas',
  uApiDARF in 'uApiDARF.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDARFViewer, frmDARFViewer);
  Application.Run;
end.
