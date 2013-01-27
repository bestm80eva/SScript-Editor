unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, SynEdit, ExtendedNotebook, Forms,
  Controls, Graphics, Dialogs, Menus, ExtCtrls, ComCtrls, mSettings;

Const SaveProjectFilter = 'Project SScript Editor (*.ssp)|*.ssp';
      OpenProjectFilter = SaveProjectFilter;

      SaveModuleFilter = 'Plik kodu SScript (*.ss)|*.ss';
      OpenModuleFilter = SaveModuleFilter;

      AnyFileFilter = 'Wszystkie pliki (*.*)|*.*';

      OpenFileFilter = OpenProjectFilter+'|'+OpenModuleFilter+'|'+AnyFileFilter;

type
  { TMainForm }
  TMainForm = class(TForm)
  oCloseProject:TMenuItem;
  oCloseCurrentCard:TMenuItem;
  MessagesImageList:TImageList;
    MenuItem1: TMenuItem;
    MenuItem7: TMenuItem;
    opSaveMessages:TMenuItem;
    opCloseAll:TMenuItem;
    oRecentlyOpened: TMenuItem;
    oNewProj_App: TMenuItem;
    oNewProj_Library: TMenuItem;
    oEvSettings: TMenuItem;
    oAbout: TMenuItem;
    opCloseCard: TMenuItem;
    MessagesPopup:TPopupMenu;
    TabsPopup: TPopupMenu;
    Splitter1: TSplitter;
    Tabs: TExtendedNotebook;
    MainMenu: TMainMenu;
    menuFile: TMenuItem;
    menuCompile: TMenuItem;
    oProjectSettings: TMenuItem;
    oOpenProject: TMenuItem;
    MenuItem3: TMenuItem;
    oSave: TMenuItem;
    MenuItem6: TMenuItem;
    oSaveAs: TMenuItem;
    oSaveAll: TMenuItem;
    oBuild: TMenuItem;
    oCompileAndRun: TMenuItem;
    oNewProject: TMenuItem;
    MenuItem2: TMenuItem;
    menuEdit: TMenuItem;
    MenuItem5: TMenuItem;
    menuProject: TMenuItem;
    oPaste: TMenuItem;
    oCopy: TMenuItem;
    oCut: TMenuItem;
    oRedo: TMenuItem;
    oUndo: TMenuItem;
    oExit: TMenuItem;
    oNewModule: TMenuItem;
    MenuItem4: TMenuItem;
    oOpen: TMenuItem;
    Panel1: TPanel;
    StatusBar: TStatusBar;
    TabsUpdate: TTimer;
    CompileStatus:TTreeView;
    procedure CompileStatusClick(Sender:TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: Array of String);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure oAboutClick(Sender: TObject);
    procedure oCloseCurrentCardClick(Sender:TObject);
    procedure oCloseProjectClick(Sender:TObject);
    procedure oEvSettingsClick(Sender: TObject);
    procedure oNewProj_AppClick(Sender: TObject);
    procedure oNewProj_LibraryClick(Sender: TObject);
    procedure opCloseAllClick(Sender:TObject);
    procedure opCloseCardClick(Sender: TObject);
    procedure oProjectSettingsClick(Sender: TObject);
    procedure oExitClick(Sender: TObject);
    procedure oOpenProjectClick(Sender: TObject);
    procedure oCompileAndRunClick(Sender: TObject);
    procedure oNewModuleClick(Sender: TObject);
    procedure oSaveAllClick(Sender: TObject);
    procedure oSaveAsClick(Sender: TObject);
    procedure oSaveClick(Sender: TObject);
    procedure oBuildClick(Sender: TObject);
    procedure oCopyClick(Sender: TObject);
    procedure oCutClick(Sender: TObject);
    procedure oOpenClick(Sender: TObject);
    procedure oPasteClick(Sender: TObject);
    procedure oRedoClick(Sender: TObject);
    procedure oUndoClick(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
    var Accept: Boolean);
    procedure TabsTabDragDropEx(Sender, Source: TObject; OldIndex,
      NewIndex: Integer; CopyDrag: Boolean; var Done: Boolean);
    procedure TabsUpdateTimer(Sender: TObject);
  private
   Procedure RecentlyOpened_Click(Sender: TObject);
  public
  end;

 Const sVersion = '0.1a';
       sCaption = 'SScript Editor v'+sVersion;
 Var MainForm      : TMainForm;
     RecentlyOpened: TStringList = nil;

 Function getProjectPnt: Pointer;

 Implementation
Uses mProject, uProjectSettings, uEvSettingsForm, uAboutForm{, LCLStrConsts};
Var Project        : TProject = nil; // currently opened project
    Splitter1Factor: Extended = 1;

{$R *.lfm}

Type TState = (stEnabled, stDisabled);

{ getProjectPnt }
Function getProjectPnt: Pointer;
Begin
 Result := Project;
End;

{ setMainMenu }
Procedure setMainMenu(State: TState);
Var B: Boolean;
    C: Integer;
Begin
 B := (State = stEnabled);

 With MainForm do
 Begin
  For C := 0 To ComponentCount-1 Do // iterate each component
  Begin
   if (Components[C] is TMenuItem) Then
    With Components[C] as TMenuItem do
    Begin
     Case Tag of
      1: Enabled := B;
      2: Enabled := not B;
     End;
    End;
  End;
 End;
End;

{ SaveProject }
Function SaveProject: Boolean;
Var Save: Boolean;
Begin
 Result := True;

 if (Project = nil) Then
  Exit;

 if (Project.Named) Then
 Begin
  if (not Project.isEverythingSaved) Then
  Begin
   { ask user }
   Save := False;
   Case MessageDlg('Zapis projektu', 'Nie wszystkie pliki z Twojego projektu są zapisane, możesz utracić dane.'#13#10'Zapisać?', mtConfirmation, mbYesNoCancel, '') of
    mrYes   : Save := True;
    mrNo    : Save := False;
    mrCancel: Exit(False);
   End;
  End;

  if (Save) Then
   Project.Save;

  Exit(True);
 End;

 { ask user }
 Save := False;
 Case MessageDlg('Zapis projektu', 'Twój aktualny projekt nie jest zapisany, możesz utracić dane.'#13#10'Zapisać projekt?', mtConfirmation, mbYesNoCancel, '') of
  mrYes   : Save := True;
  mrNo    : Save := False;
  mrCancel: Exit(False);
 End;

 if (Save) Then
  Project.Save;
End;

(* ===== TMainForm ===== *)

Procedure TMainForm.RecentlyOpened_Click(Sender: TObject);
Begin
 if (SaveProject) Then
 Begin
  setMainMenu(stDisabled);

  // close current project
  if (Project = nil) Then
   Project := TProject.Create Else
   Begin
    Project.Free;
    Project := TProject.Create;
   End;

  // open a new project
  if (Project.Open(TMenuItem(Sender).Caption)) Then
  Begin
   setMainMenu(stEnabled);
  End Else
  Begin
   With RecentlyOpened Do
    Delete(IndexOf(TMenuItem(Sender).Caption)); // remove invalid file from the list
   setRecentlyOpened(RecentlyOpened);
   Application.MessageBox('Nie można było otworzyć pliku projektu!', 'Błąd', MB_IconError);
   Project.Free;
  End;
 End;
End;

procedure TMainForm.FormCreate(Sender: TObject);
Var Str     : String;
    MenuItem: TMenuItem;
begin
 // set some values
 DefaultFormatSettings.DecimalSeparator := '.';
 Application.Title                      := Caption;

 setMainMenu(stDisabled);

 Caption        := sCaption;
 DoubleBuffered := True;

 // read config
 Splitter1Factor := abs(getFloat(sSplitter1));

 if (Splitter1Factor = 0) Then // we don't want to divide by zero...
  Splitter1Factor := 1;

 RecentlyOpened := getRecentlyOpened;

 For Str in RecentlyOpened Do
 Begin
  With oRecentlyOpened do
  Begin
   MenuItem         := TMenuItem.Create(oRecentlyOpened);
   MenuItem.Caption := Str;
   MenuItem.OnClick := @RecentlyOpened_Click;
   oRecentlyOpened.Add(MenuItem);
  End;
 End;
end;

procedure TMainForm.FormDropFiles(Sender: TObject;
  const FileNames: Array of String);
Var I: Integer = 0;
begin
 // trying to open a project?
 if (CompareText(ExtractFileExt(FileNames[0]), '.ssp') = 0) Then
 Begin
  if (not SaveProject) Then
   Exit;

  if (Project <> nil) Then
   Project.Free;
  Project := TProject.Create;
  if (not Project.Open(FileNames[0])) Then
  Begin
   Application.MessageBox(PChar('Nie można było otworzyć pliku projektu: '+FileNames[0]), 'Błąd', MB_IconError);
   Exit;
  End;

  setMainMenu(stEnabled);

  Inc(I); // do not open project's file as a module file
 End;

 // no project opened/created so far?
 if (Project = nil) Then
  Case MessageDlg('Otwieranie pliku', 'Utworzyć nowy projekt (aplikację)?', mtConfirmation, mbYesNo, '') of
   mrNo: Exit;
   mrYes:
   Begin
    Project := TProject.Create;
    Project.NewProject(ptApplication);
    setMainMenu(stEnabled);
   End;
  End;

 // open each file in its own card
 For I := I To High(FileNames) Do
  Project.OpenCard(FileNames[I]);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
 // update controls' positions
 Splitter1.ResizeControl.Height := Round(Height/Splitter1Factor);
 StatusBar.Top                  := Height*2;
end;

procedure TMainForm.FormShow(Sender: TObject);
Var FileName: String;
begin
 // if specified in parameter, open a project
 SetCurrentDir(ExtractFilePath(Application.ExeName));

 FileName := ParamStr(1);
 if (FileExists(FileName)) and (CompareText(ExtractFileExt(FileName), '.ssp') = 0) Then
 Begin
  Project := TProject.Create;
  if (not Project.Open(FileName)) Then
  Begin
   Application.MessageBox(PChar('Nie można było otworzyć pliku projektu:'#13#10+FileName), 'Błąd', MB_IconError);
   Project.Free;
  End Else
   setMainMenu(stEnabled);
 End;
end;

procedure TMainForm.oAboutClick(Sender: TObject);
begin
 AboutForm.ShowModal;
end;

procedure TMainForm.oCloseCurrentCardClick(Sender:TObject);
begin
 opCloseCard.Click;
end;

procedure TMainForm.oCloseProjectClick(Sender:TObject);
begin
 if (SaveProject) Then
 Begin
  if (Project <> nil) Then
   FreeAndNil(Project);
  setMainMenu(stDisabled);
 End;
end;

procedure TMainForm.oEvSettingsClick(Sender: TObject);
begin
 EvSettingsForm.Run;
end;

procedure TMainForm.oNewProj_AppClick(Sender: TObject);
begin
 if (SaveProject) Then
 Begin
  if (Project = nil) Then
   Project := TProject.Create Else
   Begin
    FreeAndNil(Project);
    Project := TProject.Create;
   End;

  Project.NewProject(ptApplication);
  setMainMenu(stEnabled);

  Caption := sCaption+' - nowa aplikacja';
 End;
end;

procedure TMainForm.oNewProj_LibraryClick(Sender: TObject);
begin
 if (SaveProject) Then
 Begin
  if (Project = nil) Then
   Project := TProject.Create Else
   Begin
    FreeAndNil(Project);
    Project := TProject.Create;
   End;

  Project.NewProject(ptLibrary);
  setMainMenu(stEnabled);

  Caption := sCaption+' - nowa biblioteka';
 End;
end;

procedure TMainForm.opCloseAllClick(Sender:TObject);
begin
 Project.CloseCardsExcluding(Tabs.ActivePageIndex); // close each card except this currently opened
end;

procedure TMainForm.opCloseCardClick(Sender: TObject);
begin
 Project.CloseCard(Tabs.ActivePageIndex); // close current card
end;

procedure TMainForm.oProjectSettingsClick(Sender: TObject);
begin
 ProjectSettingsForm.Run;
end;

procedure TMainForm.oExitClick(Sender: TObject);
begin
 Close;
end;

procedure TMainForm.oOpenProjectClick(Sender: TObject);
begin
 if (SaveProject) Then
 Begin
  if (Project <> nil) Then
   FreeAndNil(Project);

  oOpen.Click;
 End;
end;

procedure TMainForm.oCompileAndRunClick(Sender: TObject);
begin
 if (Project.Compile) Then
  Project.Run;
end;

procedure TMainForm.oNewModuleClick(Sender: TObject);
begin
 Project.NewNoNameCard;
end;

procedure TMainForm.oSaveAllClick(Sender: TObject);
begin
 Project.Save;
end;

procedure TMainForm.oSaveAsClick(Sender: TObject);
begin
 Project.Save;
 Project.SaveCurrentCardAs;
end;

procedure TMainForm.oSaveClick(Sender: TObject);
begin
 Project.Save;
 Project.SaveCurrentCard;
end;

procedure TMainForm.oBuildClick(Sender: TObject);
begin
 Project.Compile;
end;

procedure TMainForm.oCopyClick(Sender: TObject);
begin
 Project.getCurrentEditor.CopyToClipboard;
end;

procedure TMainForm.oCutClick(Sender: TObject);
begin
 Project.getCurrentEditor.CutToClipboard;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
 CanClose := SaveProject;
end;

procedure TMainForm.CompileStatusClick(Sender:TObject);
Var Data: Integer;
begin
 if (CompileStatus.Selected = nil) Then // nothing is selected
  Exit;

 Data := Integer(CompileStatus.Selected.Data);
 if (Data > 0) Then
  Project.RaiseMessage(Data-1);
end;

procedure TMainForm.oOpenClick(Sender: TObject);
begin
 // create open dialog
 With TOpenDialog.Create(MainForm) do
 Begin
  Try
   if (Project = nil) Then
   Begin
    Title  := 'Otwieranie projektu';
    Filter := OpenProjectFilter;
   End Else
   Begin
    Title  := 'Otwieranie modułu';
    Filter := OpenModuleFilter;
   End;

   Options := [ofPathMustExist, ofFileMustExist];

   if (Execute) Then
   Begin
    { opening a project }
    if (Project = nil) Then
    Begin
     CompileStatus.Items.Clear;

     Project := TProject.Create;
     if (not Project.Open(FileName)) Then // failed
     Begin
      Application.MessageBox('Nie można było otworzyć pliku projektu.', 'Błąd', MB_IconError);
      FreeAndNil(Project);
      setMainMenu(stDisabled);
     End Else
     Begin
      setMainMenu(stEnabled);
     End;
    End Else

    { opening a module }
    Begin
     if (not Project.OpenCard(FileName)) Then // failed
      Application.MessageBox('Nie można było otworzyć modułu.', 'Błąd', MB_IconError);
    End;
   End;
  Finally
   Free;
  End;
 End;
end;

procedure TMainForm.oPasteClick(Sender: TObject);
begin
 Project.getCurrentEditor.PasteFromClipboard;
end;

procedure TMainForm.oRedoClick(Sender: TObject);
begin
 Project.getCurrentEditor.Redo;
end;

procedure TMainForm.oUndoClick(Sender: TObject);
begin
 Project.getCurrentEditor.Undo;
end;

procedure TMainForm.Splitter1CanResize(Sender: TObject; var NewSize: Integer;
var Accept: Boolean);
begin
 Splitter1Factor := Height/NewSize;
 setFloat(sSplitter1, Splitter1Factor);
end;

procedure TMainForm.TabsTabDragDropEx(Sender, Source: TObject; OldIndex,
  NewIndex: Integer; CopyDrag: Boolean; var Done: Boolean);
begin
 if (Project <> nil) Then
  Project.SwapCards(OldIndex, NewIndex);
end;

procedure TMainForm.TabsUpdateTimer(Sender: TObject);
begin
 if (Project = nil) Then
  Exit;

 if (Project.getCurrentCard = nil) Then
  Exit;

 Project.UpdateCards;

 With Project.getCurrentEditor do
  StatusBar.Panels[0].Text := IntToStr(CaretY)+': '+IntToStr(CaretX);

 With Project.getCurrentCard do
  StatusBar.Panels[1].Text := getFileName;
end;

end.
