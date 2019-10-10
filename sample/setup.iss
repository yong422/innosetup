;@�ۼ���     �����, dydrb422@naver.com
;@�����ۼ�   2016/10/31
;@brief      �⺻�� ��ġ�� ���� ��������.


; ��ġ��ũ��Ʈ���� ���� define
#define MyAppServiceName "sample_service_name"
#define MyAppName "Sample Agent"
#define MyAppVersion "0.01"
#define MyAppPublisher "Sample, Inc."
#define MyAppURL "http://www.sample.com/"
#define MyAppExeName "sample_service_name.exe"
#define MyAppRunnerExeName "sample_runner_name.exe"
#define MyAppBuild "1"
#define VC10RedistDir "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\redist\x86\Microsoft.VC100.CRT"

; Pascal �ҽ��ڵ忡�� ����� CM
[CustomMessages]
InputFormCaption=����
InputFromDescr=Sample ���� �Է�
InputFormLabel1=Agent Key  

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{DFA63557-6878-4E47-B68E-9CD45CD67F80}
AppName={#MyAppName}
AppVersion={#MyAppVersion}.{#MyAppBuild}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\sample_agent
DisableDirPage=yes
DefaultGroupName={#MyAppName}
AllowNoIcons=yes


OutputDir=.\
OutputBaseFilename=SampleAgent-{#MyAppVersion}.{#MyAppBuild}
Compression=lzma
SolidCompression=yes
; ������ �ɼ��� �ٰ�� admin�������� ��ġ������ �������� �����.
PrivilegesRequired=admin 

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; InfoBeforeFile: "InfoBefore.txt" 
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"; InfoBeforeFile: "InfoBefore-Korean.txt"

[Files]
Source: "{#MyAppServiceName}.ini"; DestDir: "{app}\config"
Source: "Readme.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#VC10RedistDir}\msvcr100.dll"; DestDir: "{app}\bin\"
Source: "{#VC10RedistDir}\msvcp100.dll"; DestDir: "{app}\bin\";
Source: ".\temp\{#MyAppExeName}"; DestDir: "{app}\bin"; AfterInstall: WriteAgentKey
Source: ".\temp\{#MyAppRunnerExeName}"; DestDir: "{app}\bin"; AfterInstall: WriteAgentKey

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"


[Dirs]
Name: "{app}\log"; Flags: uninsneveruninstall
Name: "{app}\bin"; Flags: uninsneveruninstall
Name: "{app}\config"; Flags: uninsneveruninstall
Name: "{app}\bin\temp"; Flags: uninsneveruninstall


[Run]Filename: {sys}\sc.exe; Parameters: "create {#MyAppServiceName} start= auto binPath= ""{app}\bin\sample_service_name.exe"" DisplayName= ""{#MyAppName}"" ";
Filename: {sys}\sc.exe; Parameters: "start {#MyAppServiceName}"
; ���ν��� ������ ������ �ʿ��� Ŀ�ǵ带 ����Ѵ�.
; ���񽺷� �����ϰ��ִ� {#MyAppServiceName}�� �����ϰ� ���񽺿��� �����Ѵ�
[UninstallRun]
Filename: {sys}\sc.exe; Parameters: "stop {#MyAppServiceName}"; 
Filename: {sys}\sc.exe; Parameters: "delete {#MyAppServiceName}"; RunOnceId: DeleteFolder

; ���ν��� ����� ���丮�� ���� �����Ѵ�.
[UninstallDelete]
Type: filesandordirs; Name: "{app}\log"
Type: filesandordirs; Name: "{app}\bin"
Type: filesandordirs; Name: "{app}\config"Type: filesandordirs; Name: "{app}"

[Code]
Var
Page: TWizardPage;
Label1: TLabel;
Label2: TLabel;
Edit1: TEdit;
Edit2: TEdit;
LibPage: TInputDirWizardPage;
InstallDirectory: String;
AgentKeyString: String;

procedure DeleteFolder();
begin
    DelTree(WizardDirValue, True, True, True);
end;

// ������Ʈ���� ������ ����Ѵ�.
// �⺻�� HKEY_CURRENT_USER �� ����Ѵ�.
// �߰��� �������� ���񽺿��� HKEY_USERS �� .DEFAULT �� ����ϹǷ� �ش� registry���� ���ϰ� ���
procedure WriteRegistry();
Var
 VersionString: String;
begin
  RegWriteStringValue(HKCU, 'Software\{#MyAppServiceName}', 'NAME', '{#MyAppName}')
  RegWriteStringValue(HKCU, 'Software\{#MyAppServiceName}', 'PUBLISHER', '{#MyAppPublisher}')
  VersionString := '{#MyAppVersion}' + '.' + '{#MyAppBuild}'
  RegWriteStringValue(HKCU, 'Software\{#MyAppServiceName}', 'VERSION', VersionString)
  RegWriteStringValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'NAME', '{#MyAppName}')
  RegWriteStringValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'PUBLISHER', '{#MyAppPublisher}')
  VersionString := '{#MyAppVersion}' + '.' + '{#MyAppBuild}'
  RegWriteStringValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'VERSION', VersionString)
end;
// ���� ������Ʈ���� ������ƮŰ�� üũ�Ѵ�.
// ���񽺿��� ���Ǵ� HKEY_USERS �� .DEFAULT �� ����üũ �Ѵ�.
procedure CheckAgentKey();
Var
  MyFileString: String;
  MyKeyString: String;
begin
  if RegValueExists(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'AGENT_KEY') then
  begin
    RegQueryStringValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'AGENT_KEY', MyKeyString)
    Edit1.Text := MyKeyString
  end  else if RegValueExists(HKCU, 'Software\{#MyAppServiceName}', 'AGENT_KEY') then  
  begin
    RegQueryStringValue(HKCU, 'Software\{#MyAppServiceName}', 'AGENT_KEY', MyKeyString)
    Edit1.Text := MyKeyString
  end
end;

procedure WriteAgentKey();
Var
  MyFileString: String;
  MyKeyString: String;  
begin
  MyKeyString := Edit1.Text;
  MyFileString := WizardDirValue + '\config\{#MyAppServiceName}.ini';
  SetIniString('agent info', 'key', MyKeyString, MyFileString);
  RegWriteStringValue(HKCU, 'Software\{#MyAppServiceName}', 'AGENT_KEY', MyKeyString)
  RegWriteStringValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'AGENT_KEY', MyKeyString) 
end;


procedure  EdtOnChange (Sender: TObject);
  Var
  MyEdit : TEdit;
  begin
  MyEdit := TEdit(Sender);
  if Length(MyEdit.Text) > 0 then
    WizardForm.NextButton.Enabled := true
  Else
    WizardForm.NextButton.Enabled := false;
end;

// Custom �������� �����Ѵ�.
// CreateCustomPage�� �̿��Ͽ� custom page�� �����ϰ� ù��° ������ ������ ������ġ�� ����
// ������ ��ġ ������ wp+�������� �̸� http://www.jrsoftware.org/ishelp/index.php?topic=wizardpages ����.
procedure InitializeWizard;
Var
  CheckBox: TCheckBox;
begin  
      Page := CreateCustomPage( wpPreparing, ExpandConstant('{cm:InputFormCaption}'), ExpandConstant('{cm:InputFromDescr}') );

{ Label1 } Label1 := TLabel.Create(Page); with Label1 do begin Parent := Page.Surface; Caption := ExpandConstant('{cm:InputFormLabel1}'); Left := ScaleX(16); Top := ScaleY(24); Width := ScaleX(70); Height := ScaleY(13); end;

{ Edit1 } Edit1 := TEdit.Create(Page); with Edit1 do begin Parent := Page.Surface; Left := ScaleX(115); Top := ScaleY(24); Width := ScaleX(273); Height := ScaleY(21); TabOrder := 0; end;
  
  Edit1.OnChange := @EdtOnChange;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  If CurPageID = Page.ID Then
    WizardForm.NextButton.Enabled := true;
  end;

function InitializeUninstall(): Boolean;
begin
  // ���ν��� ���� ��. �����.
  Result := True
  //Result := MsgBox('InitializeUninstall:' #13#13 'Uninstall is initializing. Do you really want to start Uninstall?', mbConfirmation, MB_YESNO) = idYes;
  if Result = False then
    //MsgBox('InitializeUninstall:' #13#13 'Ok, bye bye.', mbInformation, MB_OK);
end;

procedure DeinitializeUninstall();
begin
  //MsgBox('DeinitializeUninstall:' #13#13 'Bye bye!', mbInformation, MB_OK);
end;

// ���Ž��� �޽���.
// usUninstall ���ν��� ����.
// usPostUninstall ���ν��� ����.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
Var
CurDir: String;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        // ���ν��� ���۽� ��ϵ� ������Ʈ��Ű�� �����Ѵ�.
        RegDeleteValue(HKCU, 'Software\{#MyAppServiceName}', 'NAME')
        RegDeleteValue(HKCU, 'Software\{#MyAppServiceName}', 'PUBLISHER')
        RegDeleteValue(HKCU, 'Software\{#MyAppServiceName}', 'VERSION')
        RegDeleteValue(HKCU, 'Software\{#MyAppServiceName}', 'AGENT_KEY')
        RegDeleteKeyIfEmpty(HKCU, 'Software\{#MyAppServiceName}')
        RegDeleteValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'NAME')
        RegDeleteValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'PUBLISHER')
        RegDeleteValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'VERSION')
        RegDeleteValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'AGENT_KEY')
        RegDeleteValue(HKU, '.DEFAULT\Software\{#MyAppServiceName}', 'AGENT_REGISTER')
        RegDeleteKeyIfEmpty(HKU, '.DEFAULT\Software\{#MyAppServiceName}')
      end;
    usPostUninstall:
      begin
        //MsgBox('CurUninstallStepChanged:' #13#13 'Uninstall just finished.', mbInformation, MB_OK);
        // ...insert code to perform post-uninstall tasks here...
        //CurDir := '{app}';
        //MsgBox(WizardDirValue, mbInformation, MB_OK);
        //DelTree(WizardDirValue, True, True, True);
      end;
  end;
end;

// InnoSetup �� NextButton Ŭ�� �̺�Ʈ callback�Լ�.
// CurPageID�� �Ѱܹ��� �������� NextButton���� �̺�Ʈ���.
function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  case CurPageID of
    //! ��ġ �غ������� NextButton Ŭ���� registry�� agent key�� üũ�Ѵ�.
    wpReady:
      begin
        CheckAgentKey();
        WriteRegistry();
      end;
  end;

  Result := True;
end;
  
[CodeEnd]
;InnoSetup�� ����ϱ����� �ʼ� ���� ����.

;[File] section
; ��ġ�� ������ ����.
; Flag �ɼ��� �ټ������� �ɼǺ��� ������ �������
;   ignoreversion : ��������
;   recursesubdirs :  ������������
;   createallsubdirs : ���������� ������ ����. recursesubdirs �� ���̻���ؾ���
;   overwritereadonly : ��������� ���ϵ� �������.
;   external : ��ġ���Ͽ� ���Ծȵ� �ܺ� ������ ��ġ
;   skipifsourcedoesntexist : �����Ͻó� ����ÿ� �ش� ������ ��� ������ ��������.
;   �̿� �پ��ѿɼ��� �ش� url ����. http://www.jrsoftware.org/ishelp/index.php?topic=filessection

;[Code] Section
; �ڵ弽�� ������ install path�� ����ؾ��Ұ��.
; �Լ�ȣ�⿡�� '{app}' ������ �������ָ� �ش� ���� �׳� ���ڿ��� ǥ�õ�.
; Code������ WizardDirValue �� ����ϸ� install path���� ���� ��밡���ϴ�.