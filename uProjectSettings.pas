unit uProjectSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons;

type

  { TProjectSettingsForm }

  TProjectSettingsForm = class(TForm)
    Bevel1: TBevel;
    eHeaderFile: TEdit;
    eBytecodeOutput: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    CompilerFile_Select: TBitBtn;
    btnSave: TButton;
    btnCancel: TButton;
    FileTimer: TTimer;
    EXEOpen: TOpenDialog;
    eOutputFile: TEdit;
    eIncludePath: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    p_3: TPage;
    VMFile_Select: TBitBtn;
    _O1: TCheckBox;
    _Op: TCheckBox;
    _dbg: TCheckBox;
    eCompilerSwitches: TEdit;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    _Of: TCheckBox;
    _ninit: TCheckBox;
    _Or: TCheckBox;
    eCompilerFile: TEdit;
    eVMFile: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    p_1: TPage;
    p_2: TPage;
    Pages: TNotebook;
    Setting: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure CompilerFile_SelectClick(Sender: TObject);
    procedure eCompilerFileChange(Sender: TObject);
    procedure eVMFileChange(Sender: TObject);
    procedure FileTimerTimer(Sender: TObject);
    procedure SettingClick(Sender: TObject);
    procedure VMFile_SelectClick(Sender: TObject);
  private
    { private declarations }
  public
   Procedure Run;
  end;

var
  ProjectSettingsForm: TProjectSettingsForm;

implementation
Uses uMainForm, mProject;
Var CheckTime: Integer = 0;

{$R *.lfm}

{ TProjectSettingsForm }

{ TProjectSettingsForm.Run }
Procedure TProjectSettingsForm.Run;
Var Switch: TCompilerSwitch;
Begin
 With TProject(getProjectPnt) do
 Begin
  { read paths }
  eCompilerFile.Text   := CompilerFile;
  eVMFile.Text         := VMFile;
  eOutputFile.Text     := OutputFile;
  eBytecodeOutput.Text := BytecodeOutput;
  eHeaderFile.Text     := HeaderFile;

  { read compiler switches }
  eCompilerSwitches.Text := OtherCompilerSwitches;
  eIncludePath.Text      := IncludePath;

  For Switch in TCompilerSwitches Do
   TCheckBox(FindComponent(getSwitchName(Switch, False))).Checked := Switch in CompilerSwitches;
 End;

 CheckTime := 0;
 FileTimer.OnTimer(FileTimer);
 ShowModal;
End;

procedure TProjectSettingsForm.SettingClick(Sender: TObject);
Var Page: Integer;
begin
 With Setting do
 Begin
  if (Selected = nil) Then
   Exit;

  if (Selected.Count = 0) Then
   Page := Selected.ImageIndex Else
   Page := Selected.Items[0].ImageIndex;

  Pages.PageIndex := Page;
 End;
end;

procedure TProjectSettingsForm.VMFile_SelectClick(Sender: TObject);
begin
 if (EXEOpen.Execute) Then
  eVMFile.Text := EXEOpen.FileName;
end;

procedure TProjectSettingsForm.btnSaveClick(Sender: TObject);
Var Switch: TCompilerSwitch;
begin
 With TProject(getProjectPnt) do
 Begin
  { save paths }
  CompilerFile   := eCompilerFile.Text;
  VMFile         := eVMFile.Text;
  OutputFile     := eOutputFile.Text;
  BytecodeOutput := eBytecodeOutput.Text;
  HeaderFile     := eHeaderFile.Text;

  { save compiler switches }
  OtherCompilerSwitches := eCompilerSwitches.Text;
  IncludePath           := eIncludePath.Text;

  CompilerSwitches := [];
  For Switch in TCompilerSwitches Do
   if (TCheckBox(FindComponent(getSwitchName(Switch, False))).Checked) Then
    Include(CompilerSwitches, Switch);

  Saved := False;

  if (Named) Then
   MainForm.Caption := uMainForm.sCaption+' - '+FileName+' <*>' Else
   MainForm.Caption := uMainForm.sCaption+' - nowy projekt <*>';
 End;

 Close;
end;

procedure TProjectSettingsForm.CompilerFile_SelectClick(Sender: TObject);
begin
 if (EXEOpen.Execute) Then
  eCompilerFile.Text := EXEOpen.FileName;
end;

procedure TProjectSettingsForm.eCompilerFileChange(Sender: TObject);
begin
 CheckTime := 4;
end;

procedure TProjectSettingsForm.eVMFileChange(Sender: TObject);
begin
 CheckTime := 4;
end;

procedure TProjectSettingsForm.FileTimerTimer(Sender: TObject);
begin
 Dec(CheckTime);

 if (CheckTime < 0) Then
 Begin
  if (not FileExists(eCompilerFile.Text)) Then
   eCompilerFile.Color := clRed Else
   eCompilerFile.Color := clWhite;

  if (not FileExists(eVMFile.Text)) Then
   eVMFile.Color := clRed Else
   eVMFile.Color := clWhite;
 End;
end;

procedure TProjectSettingsForm.btnCancelClick(Sender: TObject);
begin
 Close;
end;

end.
