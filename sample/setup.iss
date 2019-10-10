;@작성자     조용규, dydrb422@naver.com
;@최초작성   2016/10/31
;@brief      기본형 설치에 대한 예제파일.


; 설치스크립트에서 사용될 define
#define MyAppServiceName "sample_service_name"
#define MyAppName "Sample Agent"
#define MyAppVersion "0.01"
#define MyAppPublisher "Sample, Inc."
#define MyAppURL "http://www.sample.com/"
#define MyAppExeName "sample_service_name.exe"
#define MyAppRunnerExeName "sample_runner_name.exe"
#define MyAppBuild "1"
#define VC10RedistDir "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\redist\x86\Microsoft.VC100.CRT"

; Pascal 소스코드에서 사용할 CM
[CustomMessages]
InputFormCaption=설정
InputFromDescr=Sample 설정 입력
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
; 다음의 옵션을 줄경우 admin권한으로 설치파일을 실행할지 물어본다.
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
; 언인스톨 실행전 실행이 필요한 커맨드를 등록한다.
; 서비스로 동작하고있는 {#MyAppServiceName}를 정지하고 서비스에서 해제한다
[UninstallRun]
Filename: {sys}\sc.exe; Parameters: "stop {#MyAppServiceName}"; 
Filename: {sys}\sc.exe; Parameters: "delete {#MyAppServiceName}"; RunOnceId: DeleteFolder

; 언인스톨 실행시 디렉토리를 전부 삭제한다.
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

// 레지스트리에 정보를 등록한다.
// 기본은 HKEY_CURRENT_USER 를 사용한다.
// 추가로 윈도우즈 서비스에서 HKEY_USERS 의 .DEFAULT 를 사용하므로 해당 registry에도 동일값 사용
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
// 기존 레지스트리의 에이전트키를 체크한다.
// 서비스에서 사용되는 HKEY_USERS 의 .DEFAULT 를 선행체크 한다.
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

// Custom 페이지를 생성한다.
// CreateCustomPage를 이용하여 custom page를 생성하고 첫번째 변수로 페이지 생성위치를 설정
// 페이지 위치 변수는 wp+페이지명 이며 http://www.jrsoftware.org/ishelp/index.php?topic=wizardpages 참조.
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
  // 언인스톨 시작 전. 물어보기.
  Result := True
  //Result := MsgBox('InitializeUninstall:' #13#13 'Uninstall is initializing. Do you really want to start Uninstall?', mbConfirmation, MB_YESNO) = idYes;
  if Result = False then
    //MsgBox('InitializeUninstall:' #13#13 'Ok, bye bye.', mbInformation, MB_OK);
end;

procedure DeinitializeUninstall();
begin
  //MsgBox('DeinitializeUninstall:' #13#13 'Bye bye!', mbInformation, MB_OK);
end;

// 제거시작 메시지.
// usUninstall 언인스톨 시작.
// usPostUninstall 언인스톨 종료.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
Var
CurDir: String;
begin
  case CurUninstallStep of
    usUninstall:
      begin
        // 언인스톨 시작시 등록된 레지스트리키를 삭제한다.
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

// InnoSetup 의 NextButton 클릭 이벤트 callback함수.
// CurPageID로 넘겨받은 페이지의 NextButton별로 이벤트등록.
function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  case CurPageID of
    //! 설치 준비페이지 NextButton 클릭시 registry의 agent key를 체크한다.
    wpReady:
      begin
        CheckAgentKey();
        WriteRegistry();
      end;
  end;

  Result := True;
end;
  
[CodeEnd]
;InnoSetup을 사용하기위한 필수 내용 정리.

;[File] section
; 설치될 파일을 정리.
; Flag 옵션을 줄수있으며 옵션별로 다음의 기능을함
;   ignoreversion : 버젼무시
;   recursesubdirs :  하위폴더까지
;   createallsubdirs : 하위폴더가 없으면 생성. recursesubdirs 와 같이사용해야함
;   overwritereadonly : 쓰기금지된 파일도 덮어쓰기함.
;   external : 설치파일에 포함안된 외부 파일을 설치
;   skipifsourcedoesntexist : 컴파일시나 실행시에 해당 파일이 없어도 에러를 내지않음.
;   이외 다양한옵션은 해당 url 참조. http://www.jrsoftware.org/ishelp/index.php?topic=filessection

;[Code] Section
; 코드섹션 내에서 install path를 사용해야할경우.
; 함수호출에서 '{app}' 등으로 변수로주면 해당 값이 그냥 문자열로 표시됨.
; Code내에서 WizardDirValue 를 사용하면 install path값을 쉽게 사용가능하다.