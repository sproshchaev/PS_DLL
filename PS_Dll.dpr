Library PS_Dll; {D7}

uses
  ShareMem,
  SysUtils,
  Classes,
  Controls,
  Dialogs,
  Des in 'Des.pas',
  psnMD5 in 'psnMD5.pas',
  ShellApi,
  Windows,
  libeay32 in 'libeay32.pas',
  WinSock
  ;

{ *** ������ ������� �������� �������� � ������� DLL *** }

// 1. ������� RoundCurrency ��������� ������������ �� �������� �� ���������� ���������� ������ ����� �������
Function RoundCurrency(in_value : Double; accuracy : Byte) : Double;
begin
  case accuracy of
    0 : RoundCurrency:=Round(in_value);
    1 : RoundCurrency:=Round((in_value+0.0001)*10)/10;
    2 : RoundCurrency:=Round((in_value+0.00001)*100)/100;
    else
      RoundCurrency:=in_value;
  end;
end;

// 2. ������� DosToWin ����������� Dos ��������� �������� ������ � ������� ��������� Windows
Function DosToWin(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE ORD(in_string[i]) OF
          128..178 : localStr:=localStr + CHR(ORD(in_string[i])+64);
             179   : localStr:=localStr + CHR(124);
             180   : localStr:=localStr + CHR(43);
             191   : localStr:=localStr + CHR(43);
             192   : localStr:=localStr + CHR(43);
             193   : localStr:=localStr + CHR(43);
             194   : localStr:=localStr + CHR(43);
             195   : localStr:=localStr + CHR(43);
             196   : localStr:=localStr + CHR(45);
             197   : localStr:=localStr + CHR(43);
             217   : localStr:=localStr + CHR(43);
             218   : localStr:=localStr + CHR(43);
          224..239 : localStr:=localStr + CHR(ORD(in_string[i])+16);
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  DosToWin:=localStr;
end;

// 3. ������� WinToDos ����������� Windows ��������� �������� ������ � ������� ��������� Dos
Function WinToDos(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE ORD(in_string[i]) OF
             166   : localStr:=localStr + CHR(124);
             185   : localStr:=localStr + ' ';
          192..239 : localStr:=localStr + CHR(ORD(in_string[i])-64);
          240..255 : localStr:=localStr + CHR(ORD(in_string[i])-16);
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  WinToDos:=localStr;
end;

// 4. �������������� ����������� ����� � ������� ����� (, -> .), ��������������� � ��������� ����
Function ChangeSeparator(In_StringFloat: shortString): shortString;
var tranzVar: shortString;
begin
  IF Pos(',' ,In_StringFloat)<>0
    THEN
      begin
        tranzVar:=COPY(In_StringFloat, 1, Pos(',' ,In_StringFloat)-1)+'.'+COPY(In_StringFloat, Pos(',' ,In_StringFloat)+1, Length(In_StringFloat)-Pos(',' ,In_StringFloat));
        IF (Length(tranzVar)-Pos('.', tranzVar))=1 THEN tranzVar:=tranzVar+'0';
        ChangeSeparator:=tranzVar;
      end
    ELSE ChangeSeparator:=In_StringFloat+'.00';
end;

// 5. �������������� ����������� ����� � ������� ����� (. -> ,), ��������������� � ��������� ����
Function ChangeSeparator2(In_StringFloat: shortString): shortString;
var tranzVar: shortString;
begin
  IF Pos('.' ,In_StringFloat)<>0
    THEN
      begin
        tranzVar:=COPY(In_StringFloat, 1, Pos('.' ,In_StringFloat)-1)+','+COPY(In_StringFloat, Pos('.' ,In_StringFloat)+1, Length(In_StringFloat)-Pos('.' ,In_StringFloat));
        IF (Length(tranzVar)-Pos('.', tranzVar))=1 THEN tranzVar:=tranzVar+'0';
        ChangeSeparator2:=tranzVar;
      end
    ELSE ChangeSeparator2:=In_StringFloat+',00';
end;

// 6. ������������� ������ ������������ �����
Function LeftFixString (In_String: shortString; In_FixPosition: Byte): shortString;
begin
  IF Length(Trim(In_String)) >= In_FixPosition
    THEN LeftFixString:=Copy(Trim(In_String), 1, In_FixPosition)
    ELSE LeftFixString:=Trim(In_String) + StringOfChar(' ', In_FixPosition - Length(Trim(In_String)));
end;

// 7. ������������� ������ ������������ ������
Function RightFixString (In_String: shortString; In_FixPosition: Byte): shortString;
begin
  IF Length(Trim(In_String)) >= In_FixPosition
    THEN RightFixString:=Copy(Trim(In_String), 1, In_FixPosition)
    ELSE RightFixString:=StringOfChar(' ', In_FixPosition - Length(Trim(In_String))) + Trim(In_String);
end;

// 8. ������������� ������ ������������ �� ������
Function CentrFixString (In_String: shortString; In_FixPosition: Byte): shortString;
begin
  In_String:=Trim(In_String);
  IF Length(Trim(In_String)) >= In_FixPosition
    THEN CentrFixString:=Copy(Trim(In_String), 1, In_FixPosition)
    ELSE
      begin
        CentrFixString:=StringOfChar(' ', Trunc((In_FixPosition - Length(Trim(In_String)))/2)) + Trim(In_String) + StringOfChar(' ', In_FixPosition - Trunc((In_FixPosition - Length(Trim(In_String)))/2));
      end;
end;

// 9. �������������� ����� �� prn-�����
Function prnSum(In_String: shortString): shortString;
var i : 0..50;
    tmp_TrSum : ShortString;
begin
  tmp_TrSum:='';
  FOR i:=1 TO Length(In_String) DO
    begin
      IF ((In_String[i]<>' ')AND((In_String[i]='0')OR(In_String[i]='1')OR(In_String[i]='2')OR(In_String[i]='3')OR(In_String[i]='4')OR(In_String[i]='5')OR(In_String[i]='6')OR(In_String[i]='7')OR(In_String[i]='8')OR(In_String[i]='9')))
        THEN tmp_TrSum:=tmp_TrSum+In_String[i];
      // �� ����� ������ ��������� ������� ����, ����� � ������� - ��� ����������� ������� �����
      IF (In_String[i]='-')or(In_String[i]='.')or(In_String[i]=',')
        THEN tmp_TrSum:=tmp_TrSum+',';
    end;
  prnSum:=tmp_TrSum;
end;

// 10. �������������� ������ '25 000,25' � ����� 25000,25
Function TrSum(In_String: ShortString):Double;
var i : 0..50;
    tmp_TrSum : ShortString;
begin
  tmp_TrSum:='';
  FOR i:=1 TO Length(In_String) DO
    IF ((In_String[i]<>' ')AND((In_String[i]=',')OR(In_String[i]='0')OR(In_String[i]='1')OR(In_String[i]='2')OR(In_String[i]='3')OR(In_String[i]='4')OR(In_String[i]='5')OR(In_String[i]='6')OR(In_String[i]='7')OR(In_String[i]='8')OR(In_String[i]='9')))
      THEN tmp_TrSum:=tmp_TrSum+In_String[i];
  TrSum:=StrToFloat(tmp_TrSum);
end;

// 11. �������������� ��������� ���� "��.��.����" � ���������� ���� ���� Int
Function bnkDay(in_value : ShortString) : Word;
var countDate : Word;
    workindDate : TDate;
    year_var, month_var, day_var:Word;
begin
  countDate:=1;
  DecodeDate(StrToDate(in_value), year_var, month_var, day_var);
  workindDate:=StrToDate('01.01.'+IntToStr(year_var));
  WHILE workindDate<StrToDate(in_value) DO
    begin
      workindDate:=workindDate+1;
      countDate:=countDate+1;
    end; // While
  bnkDay:=countDate;
end;

// 12. ������� ����������� ���� 01.01.2002 � ������ '01/01/2002'
Function DiaStrDate(in_value : TDate) : shortString;
begin
  DiaStrDate:=COPY(DateToStr(in_value),1,2)+'/'+COPY(DateToStr(in_value),4,2)+'/'+COPY(DateToStr(in_value),7,4);
end;

// 13. ������� ����������� ���� 01.01.2002 � ������ '"01" ������ 2002 �.'
Function PropisStrDate(in_value : TDate) : shortString;
var PropisStrDateTmp:shortString;
begin
  PropisStrDateTmp:='"'+COPY(DateToStr(in_value),1,2)+'"';
  CASE StrToInt(COPY(DateToStr(in_value),4,2)) OF
       1: PropisStrDateTmp:=PropisStrDateTmp+' ������ ';
       2: PropisStrDateTmp:=PropisStrDateTmp+' ������� ';
       3: PropisStrDateTmp:=PropisStrDateTmp+' ����� ';
       4: PropisStrDateTmp:=PropisStrDateTmp+' ������ ';
       5: PropisStrDateTmp:=PropisStrDateTmp+' ��� ';
       6: PropisStrDateTmp:=PropisStrDateTmp+' ���� ';
       7: PropisStrDateTmp:=PropisStrDateTmp+' ���� ';
       8: PropisStrDateTmp:=PropisStrDateTmp+' ������� ';
       9: PropisStrDateTmp:=PropisStrDateTmp+' �������� ';
      10: PropisStrDateTmp:=PropisStrDateTmp+' ������� ';
      11: PropisStrDateTmp:=PropisStrDateTmp+' ������ ';
      12: PropisStrDateTmp:=PropisStrDateTmp+' ������� ';
     end;
  PropisStrDateTmp:=PropisStrDateTmp+COPY(DateToStr(in_value),7,4)+' �.';
  PropisStrDate:=PropisStrDateTmp;
end;

// 14. ������� ���������� � ������������ ������, ������� ������ ���������� ^
Function FindSeparator(In_String: shortString; number_of_separator: Byte): Byte;
var i,counterSeparatorVar:Byte;
begin
  FindSeparator:=0;
  counterSeparatorVar:=0;
  FOR i:=1 TO Length(In_String) DO
    begin
      IF In_String[i]='^'
        THEN  counterSeparatorVar:=counterSeparatorVar+1;
      IF (counterSeparatorVar = number_of_separator)
        THEN
          begin
            FindSeparator:=i;
            Exit;
          end;
    end;
end;

// 15. ������� ���������� � ������������ ������, ������� ������ ������������� �������
Function FindChar(In_String: shortString; In_Char: Char; number_of_separator: Byte): Byte;
var i,counterSeparatorVar:Byte;
begin
  FindChar:=0;
  counterSeparatorVar:=0;
  FOR i:=1 TO Length(In_String) DO
    begin
      IF In_String[i]=In_Char
        THEN  counterSeparatorVar:=counterSeparatorVar+1;
      IF (counterSeparatorVar = number_of_separator)
        THEN
          begin
            FindChar:=i;
            Exit;
          end;
    end;
end;

// 15+. ������� ���������� � ������������ ������� ������, ������� ������ ������������� �������
Function FindCharWideString(In_String: String; In_Char: Char; number_of_separator: Word): Word;
var i,counterSeparatorVar:Word;
begin
  FindCharWideString:=0;
  counterSeparatorVar:=0;
  FOR i:=1 TO Length(In_String) DO
    begin
      IF In_String[i]=In_Char
        THEN  counterSeparatorVar:=counterSeparatorVar+1;
      IF (counterSeparatorVar = number_of_separator)
        THEN
          begin
            FindCharWideString:=i;
            Exit;
          end;
    end;
end;

// 15++. ������� ���������� � ������������ ������� ������, ������� ������ ������������� �������
Function FindCharWideString2(In_String: WideString; In_Char: Char; number_of_separator: Word): Longword;
var i:Longword; counterSeparatorVar:Word;
begin
  FindCharWideString2:=0;
  counterSeparatorVar:=0;

  FOR i:=1 TO Length(In_String) DO
    begin

      IF COPY(In_String, i, 1)=In_Char
        THEN  counterSeparatorVar:=counterSeparatorVar+1;

      IF (counterSeparatorVar = number_of_separator)
        THEN
          begin
            FindCharWideString2:=i;
            Exit;
          end;
    end;
end;


// 16. ������� ���������� � ������������ ������, ������� �������
Function FindSpace(In_String: shortString; number_of_space: Byte): Byte;
var i,counterSpaceVar:Byte;
begin
  FindSpace:=0;
  counterSpaceVar:=0;
  FOR i:=1 TO Length(In_String) DO
    begin
      IF In_String[i]=' '
        THEN  counterSpaceVar:=counterSpaceVar+1;
      IF (counterSpaceVar = number_of_space)
        THEN
          begin
            FindSpace:=i;
            Exit;
          end;
    end;
end;

{ ������� ����� ��������� ������� In_Char � ������ In_String }
Function countCharInString(In_String:WideString;In_Char:ShortString):Word;
var In_String_tmp:WideString;
    count:Word;
begin
  count:=0;
  In_String_tmp:=In_String;
  WHILE POS(In_Char, In_String_tmp)<>0 DO
    begin
      count:=count+1;
      In_String_tmp:=COPY(In_String_tmp, POS(In_Char, In_String_tmp)+1, Length(In_String_tmp)-POS(In_Char, In_String_tmp));
    end; // While
  Result:=count;
end;

// 17. ������� ����������� Win ������ 'Abcd' -> 'ABCD'
Function Upper(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE ORD(in_string[i]) OF
          97..122  : localStr:=localStr + CHR(ORD(in_string[i])-32);
          184      : localStr:=localStr + CHR(ORD(in_string[i])-16);
          224..255 : localStr:=localStr + CHR(ORD(in_string[i])-32);
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  Upper:=localStr;
end;

// 18. ������� ����������� Win ������ 'abcd' -> 'Abcd'
Function Proper(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      IF i=1
        THEN
          CASE ORD(in_string[i]) OF
              97..122  : localStr:=localStr + CHR(ORD(in_string[i])-32);
              184      : localStr:=localStr + CHR(ORD(in_string[i])-16);
              224..255 : localStr:=localStr + CHR(ORD(in_string[i])-32);
            ELSE
              localStr:=localStr+in_string[i];
          end // Case
        ELSE
          CASE ORD(in_string[i]) OF
              65..90   : localStr:=localStr + CHR(ORD(in_string[i])+32);
              168      : localStr:=localStr + CHR(ORD(in_string[i])+16);
              192..223 : localStr:=localStr + CHR(ORD(in_string[i])+32);
            ELSE
              localStr:=localStr+in_string[i];
          end; // Case
    end;// begin
  Proper:=localStr;
end;

// 19. ������� ����������� Win ������ 'ABCD' -> 'abcd'
Function Lower(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE ORD(in_string[i]) OF
          65..90   : localStr:=localStr + CHR(ORD(in_string[i])+32);
          168      : localStr:=localStr + CHR(ORD(in_string[i])+16);
          192..223 : localStr:=localStr + CHR(ORD(in_string[i])+32);
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  Lower:=localStr;
end;

// 20. ������� ����������� ������ '1000,00' -> '1 000,00'
Function Divide1000(in_string:ShortString):ShortString;
var i, count1000: -1..100;
    afterPoint:boolean;
    tmpString:ShortString;
begin
  tmpString:='';
  IF (POS('.', in_string)<>0)or(POS(',', in_string)<>0)
    THEN
      begin
        afterPoint:=False;
        count1000:=-1;
      end
    ELSE
      begin
        afterPoint:=True;
        count1000:=0;
      end;
  FOR i:=0 TO Length(in_string)-1 DO
    begin
      IF (COPY(in_string, Length(in_string)-i, 1)='.')or(COPY(in_string, Length(in_string)-i, 1)=',') THEN afterPoint:=True;
      IF (afterPoint=True) THEN count1000:=count1000+1;
      IF (afterPoint=True)AND((count1000=3)or(count1000=6)or(count1000=9)or(count1000=12))
        THEN tmpString:=' '+COPY(in_string, Length(in_string)-i, 1)+tmpString
        ELSE tmpString:=COPY(in_string, Length(in_string)-i, 1)+tmpString;
    end;
  Divide1000:=Trim(tmpString);
end;

// 21. ������� ���������� �������� � �������� ������ �� ini-�����; ���� ��� ini - 'INIFILE_NOT_FOUND'. ���� ��� ��������� - 'PARAMETR_NOT_FOUND'
Function paramFromIniFile(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  IF FileExists(ExtractFilePath(ParamStr(0))+Trim(inIniFile))=True
    THEN
      begin
        AssignFile(iniFileVar, ExtractFilePath(ParamStr(0)) {+'\'} +Trim(inIniFile));
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);

            {IF (COPY(StrokaVar, 1, 1)<>';')AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))
              THEN
                begin
                  tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end;}

            IF (COPY(StrokaVar, 1, 1)<>';') {AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))}
              THEN
                begin

                  IF (COPY(StrokaVar, 1, POS('=', StrokaVar)-1 )=Trim(inParam))
                    THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));

                end; // If

          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        MessageDlg('�� ������ ���� '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+'!', mtError, [mbOk],0);
      end;
  IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('� ����� '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+' �� ������ �������� '+Trim(inParam)+'!', mtError, [mbOk],0);
  paramFromIniFile:=tmp_paramFromIniFile;
end;

// 21++. ������� ���������� �������� � �������� ������ �� ini-�����; ���� ��� ini - 'INIFILE_NOT_FOUND'. ���� ��� ��������� - 'PARAMETR_NOT_FOUND'
Function paramFromIniFileWithOutMessDlg(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  IF FileExists(ExtractFilePath(ParamStr(0))+Trim(inIniFile))=True
    THEN
      begin
        AssignFile(iniFileVar, ExtractFilePath(ParamStr(0)) {+'\'} +Trim(inIniFile));
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);

            {IF (COPY(StrokaVar, 1, 1)<>';')AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))
              THEN
                begin
                  tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end;}

            IF (COPY(StrokaVar, 1, 1)<>';') {AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))}
              THEN
                begin

                  IF (COPY(StrokaVar, 1, POS('=', StrokaVar)-1 )=Trim(inParam))
                    THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));

                end; // If


          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        //MessageDlg('�� ������ ���� '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+'!', mtError, [mbOk],0);
      end;
  // IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('� ����� '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+' �� ������ �������� '+Trim(inParam)+'!', mtError, [mbOk],0);

  paramFromIniFileWithOutMessDlg:=tmp_paramFromIniFile;

end;

{ 21+++. � ������� �� paramFromIniFileWithOutMessDlg - ��������� WideString }
Function paramFromIniFileWithOutMessDlg2(inIniFile:ShortString; inParam:ShortString):WideString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:WideString;
    StrokaVar:WideString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  IF FileExists(ExtractFilePath(ParamStr(0))+Trim(inIniFile))=True
    THEN
      begin
        AssignFile(iniFileVar, ExtractFilePath(ParamStr(0)) {+'\'} +Trim(inIniFile));
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);

            IF (COPY(StrokaVar, 1, 1)<>';')
              THEN
                begin
                  IF Trim(COPY(StrokaVar, 1, POS('=', StrokaVar)-1) )=Trim(inParam) THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end; // If

          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
      end;

  paramFromIniFileWithOutMessDlg2:=tmp_paramFromIniFile;

end;


// 21+. ���� �����, �� ��� � ��������-������ - ������� ���������� �������� � �������� ������ �� ini-�����; ���� ��� ini - 'INIFILE_NOT_FOUND'. ���� ��� ��������� - 'PARAMETR_NOT_FOUND'
Function paramFromIniFileWithFullPath(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  inIniFile:=Trim(inIniFile);
  IF FileExists(inIniFile)=True
    THEN
      begin
        AssignFile(iniFileVar, inIniFile);
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);

            {IF (COPY(StrokaVar, 1, 1)<>';')AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))
              THEN
                begin
                  tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end;}

            IF (COPY(StrokaVar, 1, 1)<>';') {AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))}
              THEN
                begin

                  IF (COPY(StrokaVar, 1, POS('=', StrokaVar)-1 )=Trim(inParam))
                    THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));

                end; // If


          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        MessageDlg('�� ������ ���� '+inIniFile+'!', mtError, [mbOk],0);
      end;
  IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('� ����� '+ExtractFilePath(inIniFile)+' �� ������ �������� '+Trim(inParam)+'!', mtError, [mbOk],0);
  paramFromIniFileWithFullPath:=tmp_paramFromIniFile;
end;

// 21++. ���� �����, �� ��� � ��������-������ - ������� ���������� �������� � �������� ������ �� ini-�����; ���� ��� ini - 'INIFILE_NOT_FOUND'. ���� ��� ��������� - 'PARAMETR_NOT_FOUND'
// ��� MessageDlg
Function paramFromIniFileWithFullPathWithOutMessDlg(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  inIniFile:=Trim(inIniFile);
  IF FileExists(inIniFile)=True
    THEN
      begin
        AssignFile(iniFileVar, inIniFile);
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);

            { IF (COPY(StrokaVar, 1, 1)<>';')AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))
              THEN
                begin
                  tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end;}

            IF (COPY(StrokaVar, 1, 1)<>';') {AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))}
              THEN
                begin

                  IF (COPY(StrokaVar, 1, POS('=', StrokaVar)-1 )=Trim(inParam))
                    THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));

                end; // If

          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        // MessageDlg('�� ������ ���� '+inIniFile+'!', mtError, [mbOk],0);
      end;
  // IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('� ����� '+ExtractFilePath(inIniFile)+' �� ������ �������� '+Trim(inParam)+'!', mtError, [mbOk],0);

  paramFromIniFileWithFullPathWithOutMessDlg:=tmp_paramFromIniFile;

end;


// 22. ������� ���� ini ���� � �������� � ���; ���� ��� ��������� - ������������ �������� ���������, ���� ��� - �� ��������� �������� 'INIFILE_NOT_FOUND' ��� 'PARAMETR_NOT_FOUND'
Function paramFoundFromIniFile(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // �������� �� ������
  tmp_paramFromIniFile:='PARAMETR_NOT_FOUND';
  IF FileExists(ExtractFilePath(ParamStr(0))+Trim(inIniFile))=True
    THEN
      begin
        AssignFile(iniFileVar, ExtractFilePath(ParamStr(0)) {+'\'}+Trim(inIniFile));
        Reset(iniFileVar);
        WHILE EOF(iniFileVar)=false DO
          begin
            Readln(iniFileVar, StrokaVar);
            { IF (COPY(StrokaVar, 1, 1)<>';')AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))
              THEN
                begin
                  tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));
                end;}

            IF (COPY(StrokaVar, 1, 1)<>';') {AND(COPY(StrokaVar, 1, Length(inParam))=Trim(inParam))}
              THEN
                begin

                  IF (COPY(StrokaVar, 1, POS('=', StrokaVar)-1 )=Trim(inParam))
                    THEN tmp_paramFromIniFile:=Trim(COPY(StrokaVar, (POS('=', StrokaVar)+1), 255));

                end; // If

          end; // While
        CloseFile(iniFileVar);
      end
    ELSE
      begin
        // ���� �������� ���
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
      end;
  paramFoundFromIniFile:=tmp_paramFromIniFile;
end;

// 23. ������� ��������� ����� ������ ���� 1 �� ������� ���������� ������-> '0001'
Function beforZero(in_value:Integer; in_length:Word):ShortString;
var i:Word;
    string_0:ShortString;
begin
  string_0:='';
  FOR i:=1 TO (in_length - Length(IntToStr(in_value))) DO string_0:=string_0+'0';
  beforZero:=string_0+IntToStr(in_value);
end;

// 24. ������������� ��������� �� 12-� ������ � �������� ������������ ������
Function ID12docFromJournal(In_Journal:ShortString; In_NameDoc:ShortString):Word;
var txtJournal:TextFile; StrokaVar:ShortString; tmpIDdoc:Word;
begin
  // ��������� ������ ��� ������, ���� �� ����, ����� tmpIDdoc:=0;
  tmpIDdoc:=0;
  IF FileExists(ExtractFilePath(ParamStr(0))+In_Journal)=True
    THEN
      begin
        AssignFile(txtJournal, ExtractFilePath(ParamStr(0))+In_Journal);
        Reset(txtJournal);
        WHILE EOF(txtJournal)=false DO
          begin
            Readln(txtJournal, StrokaVar);
            // ����� � ������� ����� ��������� ����� ������
            IF ((COPY(StrokaVar, 1, 1)='0')or(COPY(StrokaVar, 1, 1)='1')or(COPY(StrokaVar, 1, 1)='2')or(COPY(StrokaVar, 1, 1)='3')or(COPY(StrokaVar, 1, 1)='4')or(COPY(StrokaVar, 1, 1)='5')or(COPY(StrokaVar, 1, 1)='6')or(COPY(StrokaVar, 1, 1)='7')or(COPY(StrokaVar, 1, 1)='8')or(COPY(StrokaVar, 1, 1)='9'))
              THEN tmpIDdoc:=StrToInt(Trim(COPY(StrokaVar, 1, 12)));
          end;  // While
        CloseFile(txtJournal);
      end; // If
  // ���� ����� �� ������� ������ 999999999999
  IF tmpIDdoc=999999999999 THEN tmpIDdoc:=1 ELSE tmpIDdoc:=tmpIDdoc+1;
  // ��������� ������ ��� ������
  AssignFile(txtJournal, ExtractFilePath(ParamStr(0))+In_Journal);
  IF FileExists(ExtractFilePath(ParamStr(0))+In_Journal)=True
    THEN Append(txtJournal)
    ELSE
      begin
        ReWrite(txtJournal);
        WriteLn(txtJournal, '������ �� "�����������" (���) � �.����������');
        WriteLn(txtJournal, '����� ���������� ����');
        WriteLn(txtJournal, ' ');
        WriteLn(txtJournal, '����������� ������ ����������� ����������');
        WriteLn(txtJournal, '�����: '+DateToStr(Now));
        WriteLn(txtJournal, '------------------------------------------------------------------------------------------');
        WriteLn(txtJournal, '      #     |   ����   |                        ����������                               |');
        WriteLn(txtJournal, '------------------------------------------------------------------------------------------');
      end;
  WriteLn(txtJournal, LeftFixString(IntToStr(tmpIDdoc),12)+'|'+DateToStr(Now)+'|'+DosToWin(In_NameDoc) );
  CloseFile(txtJournal);
  // ���������
  ID12docFromJournal:=tmpIDdoc;
end;

// 25. �������������� ������ � Integer
Function dateTimeToSec(in_value_str:ShortString):Integer;
begin
  Result:=Round((StrToDate(COPY(in_value_str,1,2)+'.'+COPY(in_value_str,4,2)+'.20'+COPY(in_value_str,7,2))-StrToDate('01.01.2000')))*86400+
  StrToInt(COPY(in_value_str,16,2))+
  StrToInt(COPY(in_value_str,13,2))*60+
  StrToInt(COPY(in_value_str,10,2))*3600;
end;


// 26. �������������� String � PChar
Function StrToPchar(In_string:string):Pchar;
begin
  In_string:=In_string+#0;
  result:=StrPCopy(@In_string[1], In_string);
end;

// 27. ��������� ������� � ��� ���� � ������ InFileName ������ InString � ��������� ������� ���� InLn='Ln'
Procedure ToLogFileWithName(InFileName : shortString; InString : shortString; InLn : shortString);
var LogFile:TextFile;
begin

  { ��������� ������:
    ErrCode := AssignFile(F, 'SomeFile.Txt');
    if ErrCode = FILE_NOT_FOUND then ...

    ErrCode := ResetFile(F);
    if ErrCode = FILE_NO_ACCESS then
    if ErrCode = FILE_ALREADY_OPEN then

    ErrCode := ReadLn(F, S); //Let's assume this means read from F into S
    if ErrCode = NOT_ENOUGH_TEXT then
  }

  try
    AssignFile(LogFile, ExtractFilePath(ParamStr(0))+Trim(InFileName));
    // ������� ���� � ���������� ������ �������
    IF FileExists(ExtractFilePath(ParamStr(0))+Trim(InFileName))=True THEN Append(LogFile) ELSE ReWrite(LogFile);
    // ������� ������
    IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
    // ������� ���� � ���������� ������ �������
    CloseFile(LogFile);
  except
    {on E: Exception do WriteLn(E.Message);}
  end;

end;

// 27+. ��������� ������� � ��� ���� � ������� ������� � ������ InFileName ������ InString � ��������� ������� ���� InLn='Ln'
Procedure ToLogFileWideStringWithName(InFileName : shortString; InString : String; InLn : shortString);
var LogFile:TextFile;
begin

  { ��������� ������:
    ErrCode := AssignFile(F, 'SomeFile.Txt');
    if ErrCode = FILE_NOT_FOUND then ...

    ErrCode := ResetFile(F);
    if ErrCode = FILE_NO_ACCESS then
    if ErrCode = FILE_ALREADY_OPEN then

    ErrCode := ReadLn(F, S); //Let's assume this means read from F into S
    if ErrCode = NOT_ENOUGH_TEXT then
  }

  try
    AssignFile(LogFile, ExtractFilePath(ParamStr(0))+Trim(InFileName));
    // ������� ���� � ���������� ������ �������
    IF FileExists(ExtractFilePath(ParamStr(0))+Trim(InFileName))=True THEN Append(LogFile) ELSE ReWrite(LogFile);
    // ������� ������
    IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
    // ������� ���� � ���������� ������ �������
    CloseFile(LogFile);
  except
    {on E: Exception do WriteLn(E.Message);}
  end;

end;

// 27++ ������ ���� � ���-�����
Procedure ToLogFileWithFullName(InFileName : shortString; InString : shortString; InLn : shortString);
var LogFile:TextFile;
begin
  AssignFile(LogFile, InFileName);
  // ������� ���� � ���������� ������ �������
  IF FileExists(InFileName)=True THEN Append(LogFile) ELSE ReWrite(LogFile);
  // ������� ������
  IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
  // ������� ���� � ���������� ������ �������
  CloseFile(LogFile);
end;

// 27+++ ������ ���� � ���-����� (WideString)
Procedure ToLogFileWideStringWithFullName(InFileName : shortString; InString : WideString; InLn : shortString);
var LogFile:TextFile;
begin
  AssignFile(LogFile, InFileName);
  // ������� ���� � ���������� ������ �������
  IF FileExists(InFileName)=True THEN Append(LogFile) ELSE ReWrite(LogFile);
  // ������� ������
  IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
  // ������� ���� � ���������� ������ �������
  CloseFile(LogFile);
end;


// 28. ������� ����������� ������ ��������� � �������� �� ������� �������������� � www.beonline.ru
Function TranslitBeeLine(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE in_string[i] OF
           '�' : localStr:=localStr + 'J'; '�' : localStr:=localStr + 'TS'; '�' : localStr:=localStr + 'U'; '�' : localStr:=localStr + 'K';
           '�' : localStr:=localStr + 'E'; '�' : localStr:=localStr + 'N'; '�' : localStr:=localStr + 'G'; '�' : localStr:=localStr + 'SH';
           '�' : localStr:=localStr + 'SCH'; '�' : localStr:=localStr + 'Z'; '�' : localStr:=localStr + 'H'; '�' : localStr:=localStr + '"';
           '�' : localStr:=localStr + 'F'; '�' : localStr:=localStr + 'Y'; '�' : localStr:=localStr + 'V'; '�' : localStr:=localStr + 'A';
           '�' : localStr:=localStr + 'P'; '�' : localStr:=localStr + 'R'; '�' : localStr:=localStr + 'O'; '�' : localStr:=localStr + 'L';
           '�' : localStr:=localStr + 'D'; '�' : localStr:=localStr + 'ZH'; '�' : localStr:=localStr + 'E'; '�' : localStr:=localStr + 'YA';
           '�' : localStr:=localStr + 'CH'; '�' : localStr:=localStr + 'S'; '�' : localStr:=localStr + 'M'; '�' : localStr:=localStr + 'I';
           '�' : localStr:=localStr + 'T'; '�' : localStr:=localStr + '"'; '�' : localStr:=localStr + 'B'; '�' : localStr:=localStr + 'YU';
           //
           '�' : localStr:=localStr + 'j'; '�' : localStr:=localStr + 'ts'; '�' : localStr:=localStr + 'u'; '�' : localStr:=localStr + 'k';
           '�' : localStr:=localStr + 'e'; '�' : localStr:=localStr + 'n'; '�' : localStr:=localStr + 'g'; '�' : localStr:=localStr + 'sh';
           '�' : localStr:=localStr + 'sch'; '�' : localStr:=localStr + 'z'; '�' : localStr:=localStr + 'h'; '�' : localStr:=localStr + '"';
           '�' : localStr:=localStr + 'f'; '�' : localStr:=localStr + 'y'; '�' : localStr:=localStr + 'v'; '�' : localStr:=localStr + 'a';
           '�' : localStr:=localStr + 'p'; '�' : localStr:=localStr + 'r'; '�' : localStr:=localStr + 'o'; '�' : localStr:=localStr + 'l';
           '�' : localStr:=localStr + 'd'; '�' : localStr:=localStr + 'zh'; '�' : localStr:=localStr + 'e'; '�' : localStr:=localStr + 'ya';
           '�' : localStr:=localStr + 'ch'; '�' : localStr:=localStr + 's'; '�' : localStr:=localStr + 'm'; '�' : localStr:=localStr + 'i';
           '�' : localStr:=localStr + 't'; '�' : localStr:=localStr + '"'; '�' : localStr:=localStr + 'b'; '�' : localStr:=localStr + 'yu';
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  TranslitBeeLine:=localStr;
end;

// 29. ������� ����������� ���� 06.05.2006 (06 ��� 2006) � ������ ������� MS SQL '05.06.2006'
//     06.05.2006 10:01:05
Function formatMSSqlDate(in_value:TDate):ShortString;
begin
  formatMSSqlDate:=COPY(DateToStr(in_value),4,2)+'.'+COPY(DateToStr(in_value),1,2)+'.'+COPY(DateToStr(in_value),7,4);
end;

// 30. ������� ����������� ������ � ������� ���� � ������� TTimeStamp '04-04-2007 15:22:11 +0300' � ��� TDateTime ( ������������� �������� ����� +0300 ���� �� ��������� )
Function StrFormatTimeStampToDateTime(In_StrFormatTimeStamp:ShortString):TDateTime;
begin
  StrFormatTimeStampToDateTime:=StrToDateTime(COPY(In_StrFormatTimeStamp,1,2)+'.'+COPY(In_StrFormatTimeStamp,4,2)+'.'+COPY(In_StrFormatTimeStamp,7,4)+'.'+' '+COPY(In_StrFormatTimeStamp,12,8));
end;

// 31. ������� ����������� ������ � ������� ���� � ������� TTimeStamp '04-04-2007 15:22:11 +0300' � ������ '04.04.2007 15:22:11'  ( ������������� �������� ����� +0300 ���� �� ��������� )
Function StrTimeStampToStrDateTime(In_StrFormatTimeStamp:ShortString):ShortString;
begin
  StrTimeStampToStrDateTime:=COPY(In_StrFormatTimeStamp,1,2)+'.'+COPY(In_StrFormatTimeStamp,4,2)+'.'+COPY(In_StrFormatTimeStamp,7,4)+'.'+' '+COPY(In_StrFormatTimeStamp,12,8);
end;

// 32. ������� DateTimeToStrFormat ����������� ���� � �����  01.01.2007 1:02:00 � ������ '0101200710200'
Function DateTimeToStrFormat(In_DateTime:TDateTime):ShortString;
var DateTimeToStrFormatVar:ShortString;
begin
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStr(In_DateTime), ' ', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStrFormatVar, '.', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStrFormatVar, ':', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormat:=DateTimeToStrFormatVar;
end;

// 33. ������� ����������� ��� ������ 810 � ISO: "RUR"
Function decodeCurCodeToISO(In_CurrCode:Word):ShortString;
begin
  case In_CurrCode of
    0   : decodeCurCodeToISO:='RUR';
    4   : decodeCurCodeToISO:='AFA';  //    ������
    8   : decodeCurCodeToISO:='ALL';  //    ���
    12  : decodeCurCodeToISO:='DZD';  //    ��������� �����
    20  : decodeCurCodeToISO:='ADP';  //    ��������� ������
    31  : decodeCurCodeToISO:='AZM';  //    ��������������� �����
    32  : decodeCurCodeToISO:='ARS';  //    ������������ ����
    36  : decodeCurCodeToISO:='AUD';  //    ������������� ������
    40  : decodeCurCodeToISO:='ATS';  //    �������
    44  : decodeCurCodeToISO:='BSD';  //    ��������� ������
    48  : decodeCurCodeToISO:='BHD';  //    ����������� �����
    50  : decodeCurCodeToISO:='BDT';  //    ����
    51  : decodeCurCodeToISO:='AMD';  //    ��������� ����
    52  : decodeCurCodeToISO:='BBD';  //    ������������ ������
    56  : decodeCurCodeToISO:='BEF';  //    ����������� �����
    60  : decodeCurCodeToISO:='BMD';  //    ���������� ������
    64  : decodeCurCodeToISO:='BTN';  //    ��������
    68  : decodeCurCodeToISO:='BOB';  //    ���������
    72  : decodeCurCodeToISO:='BWP';  //    ����
    84  : decodeCurCodeToISO:='BZD';  //    ��������� ������
    90  : decodeCurCodeToISO:='SBD';  //    ������ �����������
    96  : decodeCurCodeToISO:='BND';  //    ���������� ������
    100 : decodeCurCodeToISO:='BGL';  //    ���
    104 : decodeCurCodeToISO:='MMK';  //    ����
    108 : decodeCurCodeToISO:='BIF';  //    ������������ �����
    116 : decodeCurCodeToISO:='KHR';  //    �����
    124 : decodeCurCodeToISO:='CAD';  //    ��������� ������
    132 : decodeCurCodeToISO:='CVE';  //    ������ ���� - �����
    136 : decodeCurCodeToISO:='KYD';  //    ������ ����������
    144 : decodeCurCodeToISO:='LKR';  //    ��� - ���������� �����
    152 : decodeCurCodeToISO:='CLP';  //    ��������� ����
    156 : decodeCurCodeToISO:='CNY';  //    ���� ��������
    170 : decodeCurCodeToISO:='COP';  //    ������������ ����
    174 : decodeCurCodeToISO:='KMF';  //    ����� ���������
    188 : decodeCurCodeToISO:='CRC';  //    �������������� �����
    191 : decodeCurCodeToISO:='HRK';  //    ����
    192 : decodeCurCodeToISO:='CUP';  //    ��������� ����
    196 : decodeCurCodeToISO:='CYP';  //    �������� ����
    203 : decodeCurCodeToISO:='CZK';  //    ������� �����
    208 : decodeCurCodeToISO:='DKK';  //    ������� �����
    214 : decodeCurCodeToISO:='DOP';  //    ������������� ����
    218 : decodeCurCodeToISO:='ECS';  //    �����
    222 : decodeCurCodeToISO:='SVC';  //    ������������� �����
    230 : decodeCurCodeToISO:='ETB';  //    ��������� ���
    232 : decodeCurCodeToISO:='ERN';  //    �����
    233 : decodeCurCodeToISO:='EEK';  //    �����
    238 : decodeCurCodeToISO:='FKP';  //    ���� ������������
    242 : decodeCurCodeToISO:='FJD';  //    ������ �����
    246 : decodeCurCodeToISO:='FIM';  //    �����
    250 : decodeCurCodeToISO:='FRF';  //    ����������� �����
    262 : decodeCurCodeToISO:='DJF';  //    ����� �������
    270 : decodeCurCodeToISO:='GMD';  //    ������
    276 : decodeCurCodeToISO:='DEM';  //    �������� �����
    288 : decodeCurCodeToISO:='GHC';  //    ����
    292 : decodeCurCodeToISO:='GIP';  //    ������������� ����
    300 : decodeCurCodeToISO:='GRD';  //    ������
    320 : decodeCurCodeToISO:='GTQ';  //    �������
    324 : decodeCurCodeToISO:='GNF';  //    ���������� �����
    328 : decodeCurCodeToISO:='GYD';  //    ��������� ������
    332 : decodeCurCodeToISO:='HTG';  //    ����
    340 : decodeCurCodeToISO:='HNL';  //    �������
    344 : decodeCurCodeToISO:='HKD';  //    ����������� ������
    348 : decodeCurCodeToISO:='HUF';  //    ������
    352 : decodeCurCodeToISO:='ISK';  //    ���������� �����
    356 : decodeCurCodeToISO:='INR';  //    ��������� �����
    360 : decodeCurCodeToISO:='IDR';  //    �����
    364 : decodeCurCodeToISO:='IRR';  //    �������� ����
    368 : decodeCurCodeToISO:='IQD';  //    �������� �����
    372 : decodeCurCodeToISO:='IEP';  //    ���������� ����
    376 : decodeCurCodeToISO:='ILS';  //    ����� �����������
    380 : decodeCurCodeToISO:='ITL';  //    ����������� ����
    388 : decodeCurCodeToISO:='JMD';  //    �������� ������
    392 : decodeCurCodeToISO:='JPY';  //    ����
    398 : decodeCurCodeToISO:='KZT';  //    �����
    400 : decodeCurCodeToISO:='JOD';  //    ���������� �����
    404 : decodeCurCodeToISO:='KES';  //    ��������� �������
    408 : decodeCurCodeToISO:='KPW';  //    ������ - ��������� ����
    410 : decodeCurCodeToISO:='KRW';  //    ����
    414 : decodeCurCodeToISO:='KWD';  //    ���������� �����
    417 : decodeCurCodeToISO:='KGS';  //    ���
    418 : decodeCurCodeToISO:='LAK';  //    ���
    422 : decodeCurCodeToISO:='LBP';  //    ��������� ����
    426 : decodeCurCodeToISO:='LSL';  //    ����
    428 : decodeCurCodeToISO:='LVL';  //    ���������� ���
    430 : decodeCurCodeToISO:='LRD';  //    ����������� ������
    434 : decodeCurCodeToISO:='LYD';  //    ��������� �����
    440 : decodeCurCodeToISO:='LTL';  //    ��������� ���
    442 : decodeCurCodeToISO:='LUF';  //    �������������� �����
    446 : decodeCurCodeToISO:='MOP';  //    ������
    450 : decodeCurCodeToISO:='MGF';  //    ������������� �����
    454 : decodeCurCodeToISO:='MWK';  //    �����
    458 : decodeCurCodeToISO:='MYR';  //    ������������ �������
    462 : decodeCurCodeToISO:='MVR';  //    �����
    470 : decodeCurCodeToISO:='MTL';  //    ����������� ����
    478 : decodeCurCodeToISO:='MRO';  //    ����
    480 : decodeCurCodeToISO:='MUR';  //    ������������ �����
    484 : decodeCurCodeToISO:='MXN';  //    ������������ ����
    496 : decodeCurCodeToISO:='MNT';  //    ������
    498 : decodeCurCodeToISO:='MDL';  //    ���������� ���
    504 : decodeCurCodeToISO:='MAD';  //    ������������ ������
    508 : decodeCurCodeToISO:='MZM';  //    �������
    512 : decodeCurCodeToISO:='OMR';  //    �������� ����
    516 : decodeCurCodeToISO:='NAD';  //    ������ �������
    524 : decodeCurCodeToISO:='NPR';  //    ���������� �����
    528 : decodeCurCodeToISO:='NLG';  //    ������������� �������
    532 : decodeCurCodeToISO:='ANG';  //    �������������
    533 : decodeCurCodeToISO:='AWG';  //    ���������� �������
    548 : decodeCurCodeToISO:='VUV';  //    ����
    554 : decodeCurCodeToISO:='NZD';  //    �������������� ������
    558 : decodeCurCodeToISO:='NIO';  //    ������� �������
    566 : decodeCurCodeToISO:='NGN';  //    �����
    578 : decodeCurCodeToISO:='NOK';  //    ���������� �����
    586 : decodeCurCodeToISO:='PKR';  //    ������������ �����
    590 : decodeCurCodeToISO:='PAB';  //    �������
    598 : decodeCurCodeToISO:='PGK';  //    ����
    600 : decodeCurCodeToISO:='PYG';  //    �������
    604 : decodeCurCodeToISO:='PEN';  //    ����� ����
    608 : decodeCurCodeToISO:='PHP';  //    ������������ ����
    620 : decodeCurCodeToISO:='PTE';  //    ������������� ������
    624 : decodeCurCodeToISO:='GWP';  //    ���� ������ - �����
    626 : decodeCurCodeToISO:='TPE';  //    ��������� ������
    634 : decodeCurCodeToISO:='QAR';  //    ��������� ����
    642 : decodeCurCodeToISO:='ROL';  //    ���
    643 : decodeCurCodeToISO:='RUB';  //    ���������� �����
    646 : decodeCurCodeToISO:='RWF';  //    ����� ������
    654 : decodeCurCodeToISO:='SHP';  //    ���� ������� ������
    678 : decodeCurCodeToISO:='STD';  //    �����
    682 : decodeCurCodeToISO:='SAR';  //    ���������� ����
    690 : decodeCurCodeToISO:='SCR';  //    ����������� �����
    694 : decodeCurCodeToISO:='SLL';  //    �����
    702 : decodeCurCodeToISO:='SGD';  //    ������������ ������
    703 : decodeCurCodeToISO:='SKK';  //    ��������� �����
    704 : decodeCurCodeToISO:='VND';  //    ����
    705 : decodeCurCodeToISO:='SIT';  //    �����
    706 : decodeCurCodeToISO:='SOS';  //    ����������� �������
    710 : decodeCurCodeToISO:='ZAR';  //    ����
    716 : decodeCurCodeToISO:='ZWD';  //    ������ ��������
    724 : decodeCurCodeToISO:='ESP';  //    ��������� ������
    736 : decodeCurCodeToISO:='SDD';  //    ��������� �����
    740 : decodeCurCodeToISO:='SRG';  //    ����������� �������
    748 : decodeCurCodeToISO:='SZL';  //    ���������
    752 : decodeCurCodeToISO:='SEK';  //    �������� �����
    756 : decodeCurCodeToISO:='CHF';  //    ����������� �����
    760 : decodeCurCodeToISO:='SYP';  //    ��������� ����
    764 : decodeCurCodeToISO:='THB';  //    ���
    776 : decodeCurCodeToISO:='TOP';  //    ������
    780 : decodeCurCodeToISO:='TTD';  //    ������ ��������� �
    784 : decodeCurCodeToISO:='AED';  //    ������ (���)
    788 : decodeCurCodeToISO:='TND';  //    ��������� �����
    792 : decodeCurCodeToISO:='TRL';  //    �������� ����
    795 : decodeCurCodeToISO:='TMM';  //    �����
    800 : decodeCurCodeToISO:='UGX';  //    ����������� �������
    807 : decodeCurCodeToISO:='MKD';  //    �����
    810 : decodeCurCodeToISO:='RUR';  //    ���������� �����
    818 : decodeCurCodeToISO:='EGP';  //    ���������� ����
    826 : decodeCurCodeToISO:='GBP';  //    ���� ����������
    834 : decodeCurCodeToISO:='TZS';  //    ������������ �������
    840 : decodeCurCodeToISO:='USD';  //    ������ ���
    858 : decodeCurCodeToISO:='UYU';  //    ����������� ����
    860 : decodeCurCodeToISO:='UZS';  //    ��������� ���
    862 : decodeCurCodeToISO:='VEB';  //    �������
    882 : decodeCurCodeToISO:='WST';  //    ����
    886 : decodeCurCodeToISO:='YER';  //    ��������� ����
    891 : decodeCurCodeToISO:='YUM';  //    ����� �����
    894 : decodeCurCodeToISO:='ZMK';  //    ����� (����������)
    901 : decodeCurCodeToISO:='TWD';  //    ����� �����������
    950 : decodeCurCodeToISO:='XAF';  //    ����� ��� ����
    951 : decodeCurCodeToISO:='XCD';  //    �������� - ���������
    952 : decodeCurCodeToISO:='XOF';  //    ����� ��� �����
    953 : decodeCurCodeToISO:='XPF';  //    ����� ���
    960 : decodeCurCodeToISO:='XDR';  //    ��� (����������� �����
    972 : decodeCurCodeToISO:='TJS';  //    ������
    973 : decodeCurCodeToISO:='AOA';  //    ������
    974 : decodeCurCodeToISO:='BYR';  //    ����������� �����
    975 : decodeCurCodeToISO:='BGN';  //    ���������� ���
    976 : decodeCurCodeToISO:='CDF';  //    ������������ �����
    977 : decodeCurCodeToISO:='���';  //    �������������� �����
    978 : decodeCurCodeToISO:='EUR';  //    ����
    980 : decodeCurCodeToISO:='UAH';  //    ������
    981 : decodeCurCodeToISO:='GEL';  //    ����
    985 : decodeCurCodeToISO:='PLN';  //    ������
    986 : decodeCurCodeToISO:='BRL';  //    ����������� ����
      end;
end;

// 34. �������������� ������ "01-05" � ���� 31.01.2005
Function cardExpDate_To_Date(In_cardExpDate:ShortString):TDate;
var Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(StrToDate('01.'+COPY(In_cardExpDate,1,2)+'.20'+COPY(In_cardExpDate,4,2)), Year, Month, Day);
  IF Month=12
    THEN cardExpDate_To_Date:=StrToDate('01.'+IntToStr(1)+'.'+ IntToStr(StrToInt('20'+COPY(In_cardExpDate,4,2))+1) )-1
    ELSE cardExpDate_To_Date:=StrToDate('01.'+IntToStr(Month+1)+'.20'+COPY(In_cardExpDate,4,2))-1;
end;

// 35. �������������� ������ ����� �� ������ 9-�� ������ � ��� ����� (������)
Function decodeTypeCard(In_CardNumber:ShortString):ShortString;
var decodeTypeCard_tmp:ShortString;
begin
  decodeTypeCard_tmp:='type not define';
  IF (COPY(In_CardNumber, 1, 9)='487417315') THEN decodeTypeCard_tmp:='VISA Electron';
  IF (COPY(In_CardNumber, 1, 9)='487415515') THEN decodeTypeCard_tmp:='VISA Classic';
  IF (COPY(In_CardNumber, 1, 9)='487416315') THEN decodeTypeCard_tmp:='VISA Gold';
  IF (COPY(In_CardNumber, 1, 9)='676454115') THEN decodeTypeCard_tmp:='Maestro';
  IF (COPY(In_CardNumber, 1, 9)='548999015') THEN decodeTypeCard_tmp:='MasterCard';
  IF (COPY(In_CardNumber, 1, 9)='549000215') THEN decodeTypeCard_tmp:='MasterCard Gold';

  // Union Card
  IF (COPY(In_CardNumber, 1, 6)='602208') THEN decodeTypeCard_tmp:='Union Card';
  // ���������� �����
  IF (COPY(In_CardNumber, 1, 9)='487417415') THEN decodeTypeCard_tmp:='VISA Electron ����������';
  IF (COPY(In_CardNumber, 1, 9)='487415415') THEN decodeTypeCard_tmp:='VISA Classic ����������';
  IF (COPY(In_CardNumber, 1, 9)='487416415') THEN decodeTypeCard_tmp:='VISA Gold ����������';

  decodeTypeCard:=decodeTypeCard_tmp;
end;

// 35.+ �������������� ������ ����� �� ������ 6-�� ������ � ��� ����� (�����������)
Function decodeTypeCardGPB(In_CardNumber:ShortString):ShortString;
var decodeTypeCard_tmp:ShortString;
begin
  decodeTypeCard_tmp:='type not define';
  IF (COPY(In_CardNumber, 1, 6)='487417') THEN decodeTypeCard_tmp:='VISA Electron';
  IF (COPY(In_CardNumber, 1, 6)='487415') THEN decodeTypeCard_tmp:='VISA Classic';
  IF (COPY(In_CardNumber, 1, 6)='487416') THEN decodeTypeCard_tmp:='VISA Gold';
  IF (COPY(In_CardNumber, 1, 6)='676454') THEN decodeTypeCard_tmp:='Maestro';
  IF (COPY(In_CardNumber, 1, 6)='548999') THEN decodeTypeCard_tmp:='MasterCard';
  IF (COPY(In_CardNumber, 1, 6)='549000') THEN decodeTypeCard_tmp:='MasterCard Gold';

  decodeTypeCardGPB:=decodeTypeCard_tmp;
end;


// 36. �������������� PChar � Str
Function PCharToStr(P:Pchar) :String;
begin
  Result:=P;
end;

// 37. ������� ����������� ���� 01.01.2002 � ������ '01/01/2002'
Function StrDateFormat1(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat1:=COPY(DateToStr(in_value),1,2)+'/'+COPY(DateToStr(in_value),4,2)+'/'+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat1:=COPY(DateToStr(in_value),1,2)+'/'+COPY(DateToStr(in_value),4,2)+'/'+COPY(DateToStr(in_value),7,4);
end;

// 38. ������� ����������� ���� 01.01.2002 � ������ '01-01-2002'
Function StrDateFormat2(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat2:=COPY(DateToStr(in_value),1,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat2:=COPY(DateToStr(in_value),1,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),7,4);
end;

// 39. ������ � ��������� ����� ��������(RUB) * �������........... SummaPropis(X) * �����������....... Uncle Slava * ���� ��������..... 16.11.98 * ���������......... X - �������� ������������� ����� * ����������........ ��������� ������������� ����� *  ���������:  ������������ ���������� ��������� SummaScheta, Summa, SummaCop � Ostatok ����������: ������� ����� (SummaScheta) � ��������� ��������� ����������: SummaPropis - ����� ��������  }
//Function SummaPropis(SummaScheta: Variant): ShortString;
//  var {���������� ����������} {SummaScheta:Variant;} Ostatok, Summa, OstatokCop: Variant; R, R1 : Variant; Gruppa, Dlina : Variant; Propis, PropisCop, S: String; i : Integer;
  {�������}   //  Function Edinici(R: Variant; Rod: String): String; begin case R of 1: if Rod = '�������' then Edinici := '����' else Edinici := '����'; 2: if Rod = '�������' then Edinici := '���' else Edinici := '���'; 3: Edinici := '���'; 4: Edinici := '������'; 5: Edinici := '����'; 6: Edinici := '�����'; 7: Edinici := '����'; 8: Edinici := '������'; 9: Edinici := '������'; 10: Edinici := '������'; 11: Edinici := '�����������'; 12: Edinici := '����������'; 13: Edinici := '����������'; 14: Edinici := '������������'; 15: Edinici := '����������'; 16: Edinici := '�����������'; 17: Edinici := '����������'; 18: Edinici := '������������'; 19: Edinici := '������������'; end; end;
  {�������}   //  Function Desatki(R: Variant): String; begin case R of 2: Desatki := '��������'; 3: Desatki := '��������'; 4: Desatki := '�����'; 5: Desatki := '���������'; 6: Desatki := '����������'; 7: Desatki := '���������'; 8: Desatki := '�����������'; 9: Desatki := '���������'; end; end;
  {�����}     //  Function Sotni(R: Variant): String; begin case R of 1: Sotni := '���'; 2: Sotni := '������'; 3: Sotni := '������'; 4: Sotni := '���������'; 5: Sotni := '�������'; 6: Sotni := '��������'; 7: Sotni := '�������'; 8: Sotni := '���������'; 9: Sotni := '���������'; end; end;
  {������}    //  Function Tusachi(R: Variant): String; begin If R = 1 Then Tusachi := '������' else if (R > 1) And (R < 5) then Tusachi := '������' else Tusachi := '�����'; end;
  {��������}  //  Function Millioni(R: Variant): String; begin If R = 1 Then Millioni := '�������' else if (R > 1) And (R < 5) then Millioni := '��������' else Millioni := '���������'; end;
  {���������} // Function Milliardi(R: Variant): String; begin If R = 1 Then Milliardi := '��������' else if (R > 1) And (R < 5) then Milliardi := '���������' else Milliardi := '����������'; end;
  {�������}   // Function Copeiki(R: Variant): String; begin If R = 1 Then Copeiki := '' else if (R > 1) And (R < 5) then Copeiki := '' else Copeiki := '' end;
  {�����}     // Function Rubli(R: Variant): String; begin If R = 1 Then Rubli := '' else if (R > 1) And (R < 5) then Rubli := '' else Rubli := '' end;
  { * ��������� �������������� ������� : * Abs(x)   - ������ �����.  Int(x)   - �������� ����� ����� ������������� �����. * Frac(x)  - �������� ������� ����� ������������� �����. * Round(x) - ��������� �� ������ �����. }
//begin
//  if Round(StrToFloat(SummaScheta))=0 then begin SummaPropis := '����'; Exit; end; Propis:=''; PropisCop:=''; S:=''; SummaScheta := Abs(SummaScheta); Ostatok := Int(SummaScheta); OstatokCop := Frac(SummaScheta); OstatokCop := Int(OstatokCop*100); Gruppa := Ostatok / 1000000000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000000000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10); Propis  := Propis + Sotni(R); Ostatok := Ostatok - R * 100 * 1000000000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000000000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, '�������') + ' ' + Milliardi(R); Ostatok := Ostatok - R * 1000000000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000000000; Propis  := Propis + ' ' + Milliardi(R); end; end;
//  Gruppa := Ostatok / 1000000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10); if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100 * 1000000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, '�������') + ' ' + Millioni(R); Ostatok := Ostatok - R * 1000000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000000; Propis  := Propis + ' ' + Millioni(R); end; end; Gruppa := Ostatok / 1000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10);
//  if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100 * 1000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, '�������') + ' ' + Tusachi(R); Ostatok := Ostatok - R * 1000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000; Propis  := Propis + ' ' + Tusachi(R); end; end; Gruppa := Ostatok;
//  if Gruppa <> 0 then begin R := Int(Gruppa / 100); if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, '�������'); Ostatok := Ostatok - R; end else begin R := Int(Gruppa); Ostatok := Ostatok - R; end; end else If False then begin Gruppa := OstatokCop; if Gruppa > 19 then begin R := Int(Gruppa / 10); PropisCop := PropisCop + ' ' + Desatki(R); OstatokCop := OstatokCop - R * 10; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 2 then begin R := Int(Gruppa); PropisCop := PropisCop + ' ' + Edinici(R, '�������') + ' ' + Copeiki(R); OstatokCop := OstatokCop - R; end else begin R := Int(Gruppa); OstatokCop := OstatokCop - R; PropisCop  := PropisCop + ' ' + Copeiki(R); end; end;
//  Dlina := Length(Propis); if VarIsNull(Dlina) then Exit; Propis:= Trim(Propis); S:=AnsiUpPerCase(COPY(Propis,1,1))+COPY(Propis,2,Length(Propis)-1); SummaPropis := S + PropisCop;
//end;

// 39. ����� �������� (������������� )
Function SummaPropis(In_Sum:Double): WideString;

  { ������� Conv999}
  function Conv999(M: longint; fm: integer): string;
    const c1to9m: array [1..9] of string [6]=('����','���','���','������','����','�����','����','������','������');
        c1to9f: array [1..9] of string [6]=('����','���','���','������','����','�����','����','������','������');
        c11to19: array [1..9] of string [12]=('�����������','����������','����������','������������','����������','�����������','����������','������������','������������');
        c10to90: array [1..9] of string [11]=('������','��������','��������','�����','���������','����������','���������','�����������','���������');
        c100to900: array [1..9] of string [9] =('���','������','������','���������','�������','��������','�������','���������','���������');
  var s: string; i: longint;
  begin
    s := ''; i := M div 100; if i<>0 then s:=c100to900[i]+' '; M := M mod 100; i := M div 10;
    if (M>10) and (M<20) then s:=s+c11to19[M-10]+' ' else begin if i<>0 then s:=s+c10to90[i]+' '; M := M mod 10; if M<>0 then if fm=0 then s:=s+c1to9f[M]+' ' else s:=s+c1to9m[M]+' '; end;
    Conv999 := s;
  end;
var i: longint; j: longint; r: real; t: string; //S:Double;
begin
  { ����������� ������ � ��� Double }
  //S:=In_Sum;
  { ��������� ���������� �������� }
  t := ''; j := Trunc(In_Sum/1000000000.0); r := j; r := In_Sum - r*1000000000.0; i := Trunc(r);
  if j<>0 then begin t:=t+Conv999(j,1)+'��������'; j := j mod 100; if (j>10) and (j<20) then t:=t+'�� ' else case j mod 10 of 0: t:=t+'�� '; 1: t:=t+' '; 2..4: t:=t+'� '; 5..9: t:=t+'�� '; end; end;
  j := i div 1000000;
  if j<>0 then begin t:=t+Conv999(j,1)+'�������'; j := j mod 100; if (j>10) and (j<20) then t:=t+'�� ' else case j mod 10 of 0: t:=t+'�� '; 1: t:=t+' '; 2..4: t:=t+'� '; 5..9: t:=t+'�� '; end; end;
  i := i mod 1000000; j := i div 1000;
  if j<>0 then begin t:=t+Conv999(j,0)+'�����'; j := j mod 100; if (j>10) and (j<20) then t:=t+' ' else case j mod 10 of 0: t:=t+' '; 1: t:=t+'� '; 2..4: t:=t+'� '; 5..9: t:=t+' '; end;
end;
  i := i mod 1000; j := i; if j<>0 then t:=t+Conv999(j,1);
  t := t {+'���. '};  // �� ������� ���.
  i := Round(Frac(In_Sum)*100.0);
  t := t {+IntToStr(i)+' ���.'}; // �� ������� ���.
  SummaPropis:=AnsiUpperCase(COPY(t,1,1))+COPY(t,2,(Length(t)-1));
end;

// 39+. ����� �������� (������������� )
Function SummaPropis2(In_Sum:Double): WideString;
  { ������� Conv999}
  function Conv999(M: longint; fm: integer): string;
    const c1to9m: array [1..9] of string [6]=('����','���','���','������','����','�����','����','������','������');
        c1to9f: array [1..9] of string [6]=('����','���','���','������','����','�����','����','������','������');
        c11to19: array [1..9] of string [12]=('�����������','����������','����������','������������','����������','�����������','����������','������������','������������');
        c10to90: array [1..9] of string [11]=('������','��������','��������','�����','���������','����������','���������','�����������','���������');
        c100to900: array [1..9] of string [9] =('���','������','������','���������','�������','��������','�������','���������','���������');
  var s: string; i: longint;
  begin
    s := ''; i := M div 100; if i<>0 then s:=c100to900[i]+' '; M := M mod 100; i := M div 10;
    if (M>10) and (M<20) then s:=s+c11to19[M-10]+' ' else begin if i<>0 then s:=s+c10to90[i]+' '; M := M mod 10; if M<>0 then if fm=0 then s:=s+c1to9f[M]+' ' else s:=s+c1to9m[M]+' '; end;
    Conv999 := s;
  end;
var i: longint; j: longint; r: real; t: string; //S:Double;
begin
  { ����������� ������ � ��� Double }
  //S:=In_Sum;
  { ��������� ���������� �������� }
  t := ''; j := Trunc(In_Sum/1000000000.0); r := j; r := In_Sum - r*1000000000.0; i := Trunc(r);
  if j<>0 then begin t:=t+Conv999(j,1)+'��������'; j := j mod 100; if (j>10) and (j<20) then t:=t+'�� ' else case j mod 10 of 0: t:=t+'�� '; 1: t:=t+' '; 2..4: t:=t+'� '; 5..9: t:=t+'�� '; end; end;
  j := i div 1000000;
  if j<>0 then begin t:=t+Conv999(j,1)+'�������'; j := j mod 100; if (j>10) and (j<20) then t:=t+'�� ' else case j mod 10 of 0: t:=t+'�� '; 1: t:=t+' '; 2..4: t:=t+'� '; 5..9: t:=t+'�� '; end; end;
  i := i mod 1000000; j := i div 1000;
  if j<>0 then begin t:=t+Conv999(j,0)+'�����'; j := j mod 100; if (j>10) and (j<20) then t:=t+' ' else case j mod 10 of 0: t:=t+' '; 1: t:=t+'� '; 2..4: t:=t+'� '; 5..9: t:=t+' '; end;
end;
  i := i mod 1000; j := i; if j<>0 then t:=t+Conv999(j,1);
  t := t +'���. ';
  i := Round(Frac(In_Sum)*100.0);
  //t := t + IntToStr(i) +' ���.';
  t := t + beforZero(i,2) +' ���.';
  SummaPropis2:=AnsiUpperCase(COPY(t,1,1))+COPY(t,2,(Length(t)-1));
end;

// 40. ������� ����������� ���� 01.02.2002 � ������ '2002-02-01'
Function StrDateFormat3(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat3:=COPY(DateToStr(in_value),7,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),1,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat3:=COPY(DateToStr(in_value),7,4)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),1,2);
end;

// 41. ������� �������� ��� �� ����
Function YearFromDate(In_Date:TDate):Word;
var   YearVar, MonthVar, DayVar: Word;
begin
  DecodeDate(In_Date, YearVar, MonthVar, DayVar);
  YearFromDate:=YearVar;
end;

// 42. ������� �� �������� ������ In_String �������� ���-������� MD5
Function GenHashMD5(In_String:ShortString):ShortString;
begin
  GenHashMD5:=MD5DigestToStr(MD5String(In_String));
end;

// 43. ����������� �����
function WindowsCopyFile(FromFile, ToDir : string) : boolean;
var F : TShFileOpStruct;
begin
  F.Wnd := 0; F.wFunc := FO_COPY;
  FromFile:=FromFile+#0; F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0; F.pTo:=pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  result:=ShFileOperation(F) = 0;
end;

{ 44. ����������� � ������� ���������� "Temp" ��� C:\Temp\ }
function GetTempPathSystem: ShortString;
var Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer)-1,Buffer));
end;

{ 45. ����������� �������� �������� ��� C:\WORK }
function GetCurrDir: ShortString;
var Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetCurrentDirectory(Sizeof(Buffer)-1,Buffer));
end;

{ 46. ����������� ��������� ����� ����� "D:\WORK\read.txt" -> "read.txt" }
function getShortFileName(In_FileName:ShortString):ShortString;
begin
  Result:=ExtractFileName(In_FileName);
end;

{ 47. ����������� ���� �� ����� ����� "D:\WORK\read.txt" -> "D:\WORK\" }
function getFilePath(In_FileName:ShortString):ShortString;
begin
  Result:=ExtractFilePath(In_FileName);
end;

{ 48. ����������� ��������� ����� ����� ��� ���������� "D:\WORK\read.txt" -> "read" }
function getShortFileNameWithoutExt(In_FileName:ShortString):ShortString;
begin
  Result:=COPY(ExtractFileName(In_FileName),1,POS('.',ExtractFileName(In_FileName))-1);
end;

{ 49. ������� ����������� ���� 01.02.2002 � ������ '01022002' �������� }
Function StrDateFormat4(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat4:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat4:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,4);
end;

{ 50. ������� ����������� ���� 01.02.2002 � ������ '010202' ������ }
Function StrDateFormat5(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat5:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat5:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),9,2);
end;

{ 51. ������� ����������� ���� � ����� 23.02.2009 12:37:00 � ������ �������������� }
Function StrDateFormat6(in_value : TDateTime) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,4) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
end;

{ 52. ������� ����������� ���� � ����� 23.02.2009 12:37:00 � ������ ������������ }
Function StrDateFormat7(in_value : TDateTime) : shortString;
var tmp_StrDateFormat7: shortString;
begin
  IF Length(DateToStr(in_value))=8 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),9,2);
  { ����� - ���� �� 10:00:00 }
  IF Length(TimeToStr(in_value))=7
    THEN
      begin
        tmp_StrDateFormat7:=tmp_StrDateFormat7+'0';
        tmp_StrDateFormat7:=tmp_StrDateFormat7+COPY(TimeToStr(in_value),1,1)+COPY(TimeToStr(in_value),3,2)+COPY(TimeToStr(in_value),6,2);
      end
    ELSE
      begin
        tmp_StrDateFormat7:=tmp_StrDateFormat7+COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
      end;
  { ��������� }
  StrDateFormat7:=tmp_StrDateFormat7;
end;

{ 53. ������� ������� � ������ �������� ����� ����� ��������� }
Function VariableBetweenChars(In_String: shortString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindChar(In_String, In_Char, In_CharNumberStart)+1, FindChar(In_String, In_Char, In_CharNumberEnd)-FindChar(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenChars:=VariableBetweenChars_tmp;
end;

{ 54. ������� ������� � ������ �������� ����� ����� ��������� - ������� ��������� ������� ������ }
Function VariableBetweenCharsWideString(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString:=VariableBetweenChars_tmp;
end;

{ 54+. ������� ������� � ������ �������� ����� ����� ��������� - ������� ��������� ������� ������ }
Function VariableBetweenCharsWideString2(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString2:=VariableBetweenChars_tmp;
end;

{ 54++. ������� ������� � ������ �������� ����� ����� ��������� - ������� ��������� ������� ������ }
Function VariableBetweenCharsWideString3(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString2(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString2(In_String, In_Char, In_CharNumberEnd)-FindCharWideString2(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString3:=VariableBetweenChars_tmp;
end;

{ 55. ������� ����������� ������ � ������� ���� � ������� ��������� ITD '04-04-07 15:22:11' � ��� TDateTime }
Function StrFormatDateTimeITDToDateTime(In_StrFormatDateTimeITD:ShortString):TDateTime;
begin
  StrFormatDateTimeITDToDateTime:=StrToDateTime(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2)+COPY(In_StrFormatDateTimeITD,9,9));
end;

{ 56. ������� ����������� ������ � ������� ���� � ������� ��������� ITD '04-04-07 15:22:11' � ��� TDate }
Function StrFormatDateTimeITDToDate(In_StrFormatDateTimeITD:ShortString):TDate;
begin
  StrFormatDateTimeITDToDate:=StrToDate(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2));
end;

{ 57. ������� ����������� ��� TDateTime � ��������� ������ ���� � ������� ITD }
Function DateTimeToStrFormatITDDateTime(In_DateTime:TDateTime):ShortString;
begin
  DateTimeToStrFormatITDDateTime:=COPY(DateTimeToStr(In_DateTime),1,2)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),9,11);
end;

{ 58. ������� ��� ������������ ������ In_StringForSign ��������� ��� RSA/MD5 � ������ ����� 1024 ��� � ��������� hex. � In_fileRSAPrivateKey ���������� ������ ���� � �����, ����������� RSA PRIVATE KEY }
function Sign_RSA_MD5_hex_WideStr(In_fileRSAPrivateKey:String; In_StringForSign:WideString ): WideString;
var
   Len: cardinal;
   mdctx: EVP_MD_CTX;
   inbuf, outbuf: array of char;
   key: pEVP_PKEY;
   a : pEVP_PKEY;
   keyfile: pBIO;
   nTamanho : integer;
   FileStream: TFileStream;
   oST : TStringStream;
begin

     { ��������� ������� �����, ����������� RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_WideStr: ���� '+In_fileRSAPrivateKey+' �� ������!');

           { ������ ����������� ����� "RSA PRIVATE KEY"

           -----BEGIN RSA PRIVATE KEY-----
           MIICXQIBAAKBgQCargbCJN+e7X80hawa+7hv4QjiEv6SisYsaVJ5HYqCCMYVYlsd
           mnbF4AK7VJTEpJrdKs64DPAbbAPWKFHeH6U2CEBurrveoejznksC6NI57SAoEev2
           ORGyhmwhrk5ztDJWJmaKv5Ne+YKRnVeMCgxZZe5LoxCmcQnmcUmIE/D7VwIDAQAB
           AoGADiY7MglDd3tMNpa/vpwmK/3O3TdVmDwfkrJzu+aK5Ag/bndX1GZr1P//3/kF
           vtM7411mGYn9cNS5qR55FrOYXiuLdNr2n550oCNTFvR7dwty3vewDHX74ybmlouU
           K1swtLaYYqd2GbyH1od9Pkqe1XOF4ayO9tO+r1EQhkNiyOECQQDKubFVTGJGMQAL
           oOSQBYIj2vQT6xT1B0ZHr1mFpkpYEZXEuPBt8xRGF42yyy4Zx4lNrw1Cv9jKEhzx
           Cbe4f4pHAkEAw1QT446MU1amf1p3hwc9fZsEUAilOZtDWGmfHWVK6JKvanh4dmc7
           r3cDF0RsStW9wp1kyhrEvWhODzkjarp+cQJBAKpTgEoRhlRBIS+j+8WBy0kC0qXV
           kuMYPJVIH6gqAjaid7o0RFWssTD+4yAAk/g27Qam+DZH6AZHV6exKXpLNksCQQCg
           Zpj2k4bUoSGVD3t8XQu36+a8unzEM6Y4InRRtW6wUlTOwCNcSCYRT1AweTXctm1g
           NdQgy56oU9FWWvukl4VhAkBuBRx5Xm6ZK13AG2uvTjA1Gjn5miuyufcuSj6DGeK7
           XQuxyS71pJ2nrRs3vAFjzytULpdfrxJa3gpdH+ZJdtQO
           -----END RSA PRIVATE KEY-----
           }

         end;

     { ���������� �� ���� ������, ������� �� ��������� ������� �����
     if FileExists(In_StringForSign) = false then
     begin
          raise Exception.Create('Arquivo para ser assinado nao foi encontrado.');
     end;}

     a := nil;

     OpenSSL_add_all_algorithms;   //
     OpenSSL_add_all_ciphers;      // InitOpenSSL
     OpenSSL_add_all_digests;      //
     ERR_load_crypto_strings;      //

     try
        keyfile := BIO_new(BIO_s_file());
        BIO_read_filename(keyfile, PChar(In_fileRSAPrivateKey));
        key := PEM_read_bio_PrivateKey(keyfile, a, nil, nil);
        if key = nil then
        begin
             raise Exception.Create('Sign_RSA_MD5_hex_WideStr: ������ ������ PRIVATE KEY �� ����� '+In_fileRSAPrivateKey+' !');
        end;

        //FileStream := TFileStream.Create(In_StringForSign, fmOpenRead);
        //nTamanho := FileStream.Size;

        oST := TStringStream.Create('');

        //oST.CopyFrom(FileStream,nTamanho);

        { ������ � oST ������ �� FileStream }
        oST.WriteString(In_StringForSign);

        { ������ ������ }
        nTamanho:=Length(In_StringForSign);

        if nTamanho < 1024 then
        begin
             nTamanho := 1024;
        end;

        SetLength(inbuf,nTamanho + 1);
        SetLength(outbuf,nTamanho + 1);

        StrPCopy(pchar(inbuf), oST.DataString);
        oST.Free;

        //FileStream.Free;

        EVP_SignInit(@mdctx, EVP_md5());
        EVP_SignUpdate(@mdctx, pchar(inbuf), StrLen(pchar(inbuf)));
        EVP_SignFinal(@mdctx, pchar(outbuf), Len, key);

        BIO_free(keyfile);

        BinToHex(pchar(outbuf),pchar(inbuf),Len);
        inbuf[2*Len]:=#0;

        { ��������� ������� � �������� ������� �������� - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 59. ������� ��� ����� In_StringForSign ��������� ��� RSA/MD5 � ������ ����� 1024 ��� � ��������� hex. � In_fileRSAPrivateKey ���������� ������ ���� � �����, ����������� RSA PRIVATE KEY }
function Sign_RSA_MD5_hex_File(In_fileRSAPrivateKey:String; In_FileNameForSign:WideString ): WideString;
var
   Len: cardinal;
   mdctx: EVP_MD_CTX;
   inbuf, outbuf: array of char;
   key: pEVP_PKEY;
   a : pEVP_PKEY;
   keyfile: pBIO;
   nTamanho : integer;
   FileStream: TFileStream;
   oST : TStringStream;
begin

     { ��������� ������� �����, ����������� RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_File: ���� '+In_fileRSAPrivateKey+' �� ������!');

           { ������ ����������� ����� "RSA PRIVATE KEY"

           -----BEGIN RSA PRIVATE KEY-----
           MIICXQIBAAKBgQCargbCJN+e7X80hawa+7hv4QjiEv6SisYsaVJ5HYqCCMYVYlsd
           mnbF4AK7VJTEpJrdKs64DPAbbAPWKFHeH6U2CEBurrveoejznksC6NI57SAoEev2
           ORGyhmwhrk5ztDJWJmaKv5Ne+YKRnVeMCgxZZe5LoxCmcQnmcUmIE/D7VwIDAQAB
           AoGADiY7MglDd3tMNpa/vpwmK/3O3TdVmDwfkrJzu+aK5Ag/bndX1GZr1P//3/kF
           vtM7411mGYn9cNS5qR55FrOYXiuLdNr2n550oCNTFvR7dwty3vewDHX74ybmlouU
           K1swtLaYYqd2GbyH1od9Pkqe1XOF4ayO9tO+r1EQhkNiyOECQQDKubFVTGJGMQAL
           oOSQBYIj2vQT6xT1B0ZHr1mFpkpYEZXEuPBt8xRGF42yyy4Zx4lNrw1Cv9jKEhzx
           Cbe4f4pHAkEAw1QT446MU1amf1p3hwc9fZsEUAilOZtDWGmfHWVK6JKvanh4dmc7
           r3cDF0RsStW9wp1kyhrEvWhODzkjarp+cQJBAKpTgEoRhlRBIS+j+8WBy0kC0qXV
           kuMYPJVIH6gqAjaid7o0RFWssTD+4yAAk/g27Qam+DZH6AZHV6exKXpLNksCQQCg
           Zpj2k4bUoSGVD3t8XQu36+a8unzEM6Y4InRRtW6wUlTOwCNcSCYRT1AweTXctm1g
           NdQgy56oU9FWWvukl4VhAkBuBRx5Xm6ZK13AG2uvTjA1Gjn5miuyufcuSj6DGeK7
           XQuxyS71pJ2nrRs3vAFjzytULpdfrxJa3gpdH+ZJdtQO
           -----END RSA PRIVATE KEY-----
           }

         end;

     { ��������� ������� ����� }
     if FileExists(In_FileNameForSign) = false then
     begin
          raise Exception.Create('Sign_RSA_MD5_hex_File: �� ������ ���� '+In_FileNameForSign+'!');
     end;

     a := nil;

     OpenSSL_add_all_algorithms;   //
     OpenSSL_add_all_ciphers;      // InitOpenSSL
     OpenSSL_add_all_digests;      //
     ERR_load_crypto_strings;      //

     try
        keyfile := BIO_new(BIO_s_file());
        BIO_read_filename(keyfile, PChar(In_fileRSAPrivateKey));
        key := PEM_read_bio_PrivateKey(keyfile, a, nil, nil);
        if key = nil then
        begin
             raise Exception.Create('Sign_RSA_MD5_hex_File: ������ ������ PRIVATE KEY �� ����� '+In_fileRSAPrivateKey+' !');
        end;

        FileStream := TFileStream.Create(In_FileNameForSign, fmOpenRead);
        nTamanho := FileStream.Size;

        oST := TStringStream.Create('');
        oST.CopyFrom(FileStream,nTamanho);

        if nTamanho < 1024 then
        begin
             nTamanho := 1024;
        end;

        SetLength(inbuf,nTamanho + 1);
        SetLength(outbuf,nTamanho + 1);

        StrPCopy(pchar(inbuf), oST.DataString);
        oST.Free;

        //FileStream.Free;

        EVP_SignInit(@mdctx, EVP_md5());
        EVP_SignUpdate(@mdctx, pchar(inbuf), StrLen(pchar(inbuf)));
        EVP_SignFinal(@mdctx, pchar(outbuf), Len, key);

        BIO_free(keyfile);

        BinToHex(pchar(outbuf),pchar(inbuf),Len);
        inbuf[2*Len]:=#0;

        { ��������� ������� � �������� ������� �������� - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 60. ������� ���������� ��������� ����� ����� ��������� ������� �������� ������������ � �������� ��������� (��������� mixing ������) }
Function mixingString(In_String:ShortString):ShortString;
var maxLengtIn_String:Word;
    s_tmp :ShortString;
    myHour, myMin, mySec, myMilli, mySecStamp : Word;
    i, posInS : Word;
begin

  { ��������� ���� }
  DecodeTime(Time, myHour, myMin, mySecStamp, myMilli);

  { ���������� ����� � �������� ������ }
  maxLengtIn_String:=Length(In_String);

  { �������� �������� ��� ������ � �������� ����������� �������� }
  IF (maxLengtIn_String MOD 2)=0
    THEN
      begin
        { ���� ����� �����, �� ��������� 1 ������ }
        In_String:=In_String+COPY(In_String,1,1);
      end; // If

  { ���� }
  FOR i:=1 TO (mySecStamp+7) DO
    begin

      { ��������� ��������� ��� ������ ������ ����� }
      IF (i MOD 2)=0
        THEN
          begin
            In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);
          end // If
        ELSE
          begin
            { ��������� ��������� ��� ������ �������� ����� }
            In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);
          end;

      { ��������� ���� }
      DecodeTime(Time, myHour, myMin, mySec, myMilli);

      { ��������� ��������� � ����������� �� �������� ����������� }
      IF (myMilli MOD 2)=0
        THEN In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);

      { ��������� ��������� � ����������� �� �������� ������ }
      IF (mySec mod 2)=0
        THEN In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);

      { ��������� ��������� � ����������� �� �������� ����� }
      IF (myMin mod 2)=0
        THEN In_String:=COPY(In_String,1,(Length(In_String) DIV 2)-1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1), (Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2), Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1))-(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)+1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1),1,(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)-1);

      { ������ ������������ ����� 1-�� � 2-�� �������� � ��� �� ����� ������������������� }
      s_tmp:=''; posInS:=1;
      WHILE (posInS<Length(In_String)) DO
        begin
          //Application.ProcessMessages;
          { ����� ������������ }
          DecodeTime(Time, myHour, myMin, mySec, myMilli);
          IF (Random(myMilli) MOD 2)=0 THEN s_tmp:=s_tmp+In_String[posInS]+In_String[posInS+1] ELSE s_tmp:=s_tmp+In_String[posInS+1]+In_String[posInS];
          posInS:=posInS+2;
        end;
      IF posInS>=Length(In_String) THEN s_tmp:=s_tmp+In_String[posInS];
      { ��������� }
      In_String:=s_tmp;
      //Application.ProcessMessages;
    end; // For

  { �������� ����� � �������� }
  IF maxLengtIn_String<>Length(In_String) THEN In_String:=COPY(In_String,2,Length(In_String)-1);

  Result:=In_String;
end;

{ 61. ������� ��������� StrToFloat � ��������� � In_String �����������, ���������������� ��������-�������������� }
Function StrToFloat2(In_String:ShortString):Extended;
var pcLCA: array [0..20] of Char;
begin

  { ���������� ��������� ���������� LOCALE_SDECIMAL }
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, pcLCA, 19);

  { ���� � In_String ����������� "." � � ������� "," }
  IF (POS('.', In_String)<>0)AND(POS(',', In_String)=0)AND(pcLCA[0]=',')
    THEN  In_String:=StringReplace(In_String, '.', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  { ���� � In_String ����������� "," � � ������� "." }
  IF (POS(',', In_String)<>0)AND(POS('.', In_String)=0)AND(pcLCA[0]='.')
    THEN  In_String:=StringReplace(In_String, ',', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  Result:=StrToFloat(In_String);

end;

{ 62. ������� �������� ����� � ��������� ���� � ����������� ����������� � �����, ������� � �������
    123 -> 123.00
    123 -> 123,00

    SumFormat('123', '.', 2)
               }
Function SumFormat(In_SumStr:ShortString; In_Separator:ShortString; In_Decimal:Word):ShortString;
var tmp_Sum:ShortString;
    i:Word;
    minus:Boolean;
begin

  In_SumStr:=Trim(In_SumStr);

  { ���������� ���� }
  IF COPY(In_SumStr,1,1)='-'
    THEN
      begin
        minus:=True;
        In_SumStr:=COPY(In_SumStr, 2, Length(In_SumStr)-1);
      end
    ELSE minus:=False;

  { ���������� - ���� �� �����������. �� ����� ����: "." "," "=" }
  tmp_Sum:='';

  FOR i:=1 TO Length(In_SumStr) DO
    begin

      IF ((In_SumStr[i]<>' ')AND((In_SumStr[i]='0')OR(In_SumStr[i]='1')OR(In_SumStr[i]='2')OR(In_SumStr[i]='3')OR(In_SumStr[i]='4')OR(In_SumStr[i]='5')OR(In_SumStr[i]='6')OR(In_SumStr[i]='7')OR(In_SumStr[i]='8')OR(In_SumStr[i]='9')))
        THEN tmp_Sum:=tmp_Sum+In_SumStr[i];

      // ������ ����������� ������� �����
      IF (In_SumStr[i]='-')or(In_SumStr[i]='.')or(In_SumStr[i]=',')or(In_SumStr[i]='=') THEN tmp_Sum:=tmp_Sum+In_Separator;

    end; // For

  { ����������� }
  IF (POS(In_Separator, tmp_Sum)=0)AND(In_Decimal<>0)
    THEN tmp_Sum:=tmp_Sum+In_Separator;

  { ���� In_Decimal=0, �� ������� ������ �� ������������ ��� ������� 0 }
  IF (In_Decimal=0)
    THEN
      begin
        IF (POS('1',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('2',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('3',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('4',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('5',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('6',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('7',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('8',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('9',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)
          THEN tmp_Sum:=COPY(tmp_Sum, 1, POS(In_Separator, tmp_Sum)-1 );
      end; // If

  { ���� ���� �����������, �� ������� ����� ������ ����� ���� � ���� ��� ����� ������ ��� In_Decimal - ��������� ������ }
  IF (POS(In_Separator, tmp_Sum)<>0)AND( ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) <In_Decimal)
    THEN
      begin
        FOR i:=1 TO ( In_Decimal - ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) ) DO
          begin
            tmp_Sum:=tmp_Sum+'0';
          end;
      end; // If

  { ����������� ���� }
  IF minus=True THEN Result:='-'+tmp_Sum ELSE Result:=tmp_Sum;

end;




{ ������� ����������� ��� TDateTime � ��������� ������ ���� � ������� ��� ������� "������" 2009-06-09T01:01:01.123456 }
Function DateTimeToStrFormatSirenaDateTime(In_DateTime:TDateTime):ShortString;
var  myHour, myMin, mySec, myMilli : Word;
begin
  { ��������� ���� }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );
  DateTimeToStrFormatSirenaDateTime:=COPY(DateTimeToStr(In_DateTime),7,4)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),1,2)
                                       +'T'
                                         { ����� }
                                         +beforZero(myHour,2)+':'+beforZero(myMin,2)+':'+beforZero(mySec,2)
                                         {+COPY(DateTimeToStr(In_DateTime), POS(' ', DateTimeToStr(In_DateTime))+1, Length(DateTimeToStr(In_DateTime))-POS(' ', DateTimeToStr(In_DateTime)))}
                                           { ������������ ����� ����� }
                                           +'.'+beforZero(myMilli,6);
end;

{ ������� ����������� ���� 01.02.2002 � ������ '020201' ������ }
Function StrDateFormat8(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat8:=COPY(DateToStr(in_value),7,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat8:=COPY(DateToStr(in_value),9,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
end;

{ ������� ����������� ���� � ����� 23.02.2009 12:37:00 � ������ ������������Ms }
Function StrDateFormat9(In_DateTime : TDateTime) : shortString;
var tmp_StrDateFormat9: shortString;
    myHour, myMin, mySec, myMilli : Word;
begin

  { ��������� ���� }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );

  IF Length(DateToStr(In_DateTime))=8 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),7,2);
  IF Length(DateToStr(In_DateTime))=10 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),9,2);
  { ����� - ���� �� 10:00:00 }
  IF Length(TimeToStr(In_DateTime))=7
    THEN
      begin
        tmp_StrDateFormat9:=tmp_StrDateFormat9+'0';
        tmp_StrDateFormat9:=tmp_StrDateFormat9+COPY(TimeToStr(In_DateTime),1,1)+COPY(TimeToStr(In_DateTime),3,2)+COPY(TimeToStr(In_DateTime),6,2);
      end
    ELSE
      begin
        tmp_StrDateFormat9:=tmp_StrDateFormat9+COPY(TimeToStr(In_DateTime),1,2)+COPY(TimeToStr(In_DateTime),4,2)+COPY(TimeToStr(In_DateTime),7,2);
      end;
  { ��������� }
  StrDateFormat9:=tmp_StrDateFormat9+IntToStr(myMilli);
end;

{  ������� ����������� ���� � ����� 23.02.2009 12:37:00 � ������ �������������� }
Function StrDateFormat10(in_value : TDateTime) : shortString;
begin
  Result:='';

  IF Length(DateToStr(in_value))=8
    THEN Result:=Result+COPY(DateToStr(in_value),7,2)
                          +COPY(DateToStr(in_value),4,2)
                          +COPY(DateToStr(in_value),1,2);

  IF Length(DateToStr(in_value))=10
    THEN Result:=Result+COPY(DateToStr(in_value),7,4)
                          +COPY(DateToStr(in_value),4,2)
                          +COPY(DateToStr(in_value),1,2);

  IF Length(TimeToStr(in_value))=7
    THEN Result:=Result+'0'+COPY(TimeToStr(in_value),1,1)+COPY(TimeToStr(in_value),3,2)+COPY(TimeToStr(in_value),6,2);

  IF Length(TimeToStr(in_value))=8
    THEN Result:=Result+COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);

end;


{ ��������� UserName }
Function RandomUserName(PWLen: Word): ShortString;
var
  StrTableUserName: ShortString;
  N, K, X, Y: integer;// ��������� ������������ ����� ������
  Flags: TReplaceFlags;
begin

  { ������� ��������, ������������ � ������ }
  StrTableUserName:='1234567890';

  { ������� ������������ ������� ��������, ��������� - mixingString }
  StrTableUserName:=DateTimeToStrFormat(Now)+StrTableUserName+DateTimeToStrFormat(Now);
  StrTableUserName:=mixingString(StrTableUserName);

  { ������� �� ���� ������������: ���� }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserName:=StringReplace(StrTableUserName, '0', '', Flags);

  if (PWlen > Length(StrTableUserName))
    then K := Length(StrTableUserName)-1
      else K := PWLen;
  SetLength(result, K); // ������������� ����� �������� ������
  Y := Length(StrTableUserName); // ����� ������� ��� ����������� �����
  N := 0; // ��������� �������� �����

  while N < K do
    begin// ���� ��� �������� K ��������
      X := Random(Y) + 1; // ���� ��������� ��������� ������
      // ��������� ����������� ����� ������� � �������� ������
      if (pos(StrTableUserName[X], result) = 0)
        then
          begin
            inc(N); // ������ �� ������
            Result[N]:=StrTableUserName[X]; // ������ ��� ���������
          end; // If
    end; // While
end;

{ ��������� UserPassword }
Function RandomUserPassword(PWLen: Word): ShortString;
var
  N, K, X, Y: integer;// ��������� ������������ ����� ������
  StrTableUserPassword:ShortString;
  Flags: TReplaceFlags;
begin

  { ������� ��������, ������������ � ������ }
  // StrTableUserPassword:='1lwEkj532hefy89r4U38LEL384FV37847rfWFWKLlvhEERnsdfkiesu38KL543789JH332U84hfgHFgfdDY7Jhh8u4jc878weDfq534sxnewg4653sHyt28dh37dh36dh3kglgnbvhrf743jdjh437edhgafdh46sgd63g63GDJASG36d4GD5Wj5gf32HGXD';
  StrTableUserPassword:='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789';

  { ������� ������������ ������� ��������, ��������� - mixingString }
  StrTableUserPassword:=DateTimeToStrFormat(Now)+StrTableUserPassword+DateTimeToStrFormat(Now);
  StrTableUserPassword:=mixingString(StrTableUserPassword);

  { ������� �� ���� ������������: ���� }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserPassword:=StringReplace(StrTableUserPassword, '0', '', Flags);

  { ������� �� ���� ������������: "o" � "O" }
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'o', '', Flags);
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'O', '', Flags);

  if (PWlen > Length(StrTableUserPassword))
    then K := Length(StrTableUserPassword)-1
      else K := PWLen;
  SetLength(result, K); // ������������� ����� �������� ������
  Y := Length(StrTableUserPassword); // ����� ������� ��� ����������� �����
  N := 0; // ��������� �������� �����

  while N < K do
    begin// ���� ��� �������� K ��������
      X := Random(Y) + 1; // ���� ��������� ��������� ������
      // ��������� ����������� ����� ������� � �������� ������
      if (pos(StrTableUserPassword[X], result) = 0)
        then
          begin
            inc(N); // ������ �� ������
            Result[N]:=StrTableUserPassword[X]; // ������ ��� ���������
          end; // If
    end; // While
end;

// ������� ����������� ������������ ������ ��� ������ � ����������
Function RussianDayOfWeek(In_DayOfWeek:Byte):Byte;
begin
  IF in_DayOfWeek = 1
    THEN
      RussianDayOfWeek:=7
    ELSE
      RussianDayOfWeek:=in_DayOfWeek-1
end;

// ������� ����������� ������������ ������ ��� ������ � ���������� �� ����
Function RussianDayOfWeekFromDate(In_Date:TDate):Byte;
var DayOfWeekVar:Byte;
begin

  DayOfWeekVar:=DayOfWeek( In_Date );

  IF DayOfWeekVar = 1
    THEN Result:=7
      ELSE Result:=DayOfWeekVar-1
end;

{ ���������� �������� ���� (����., ����.) ����� 2-�� ������ }
Function daysOffBetweenDates(In_DateBegin:TDate; In_DateEnd:TDate):Word;
var currDate:TDate;
begin
  Result:=0;
  currDate:=In_DateBegin;
  WHILE currDate<=In_DateEnd DO
    begin
      {IF (RussianDayOfWeekFromDate(currDate)=6)OR(RussianDayOfWeekFromDate(currDate)=7)}
      IF ( (RussianDayOfWeekFromDate(currDate)=6)OR(RussianDayOfWeekFromDate(currDate)=7) ) AND (currDate<>In_DateBegin)
        THEN Result:=Result+1;
      currDate:=currDate+1;
    end;
end;

{ ��������� ��������� (ShortString) �� ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " - ������������ � ��������_�����_1 � ��������_�����_11 }
Function paramFromString(In_StringAnswer:WideString; In_Param:ShortString):ShortString;
begin
  { ������ �� ������������ � ��������: "��������_�����_1" � "��������_�����_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ ��������� ��������� (WideString) �� ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " - ������������ � ��������_�����_1 � ��������_�����_11 }
Function paramFromString2(In_StringAnswer:WideString; In_Param:ShortString):WideString;
begin
  { ������ �� ������������ � ��������: "��������_�����_1" � "��������_�����_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ ��������� ��������� (WideString) �� ������ "��������_�����_1=100.00; ��������_�����_2=200.00; "
   - ������������ � ��������_�����_1 � ��������_�����_11.
   - ������������ � ��������: "��������_�����_1" � "��������_�����_1" }
Function paramFromString3(In_StringAnswer:WideString; In_Param:ShortString):WideString;
var In_StringAnswer_tmp:WideString;
    In_Param_tmp:ShortString;
begin
  In_Param_tmp:=AnsiLowerCase(In_Param);
  In_StringAnswer_tmp:=AnsiLowerCase(In_StringAnswer);

  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS('=', In_Param_tmp)=0 THEN In_Param_tmp:=In_Param_tmp+'=';

  IF POS(In_Param_tmp, In_StringAnswer_tmp)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ ���������� �������� ��������� � ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " }
Function setParamFromString(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):ShortString;
var beforeSubstring, afterSubstring:ShortString; //str1:ShortString;
begin
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  { ���� �������� ���� � ������ }
  IF POS(In_Param, In_StringAnswer)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param, In_StringAnswer)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { ���� ��������� ��� � ������, �� ���������� ��� � ����� }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ ���������� �������� ��������� (WideString) � ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " ������, �������������� � ��������! }
Function setParamFromString2(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):WideString;
var beforeSubstring, afterSubstring:WideString;
    In_StringAnswer_tmp:WideString;
    In_Param_tmp:ShortString;
begin

  { ������, �������������� � ��������! }
  In_Param_tmp:=AnsiLowerCase(In_Param);
  In_StringAnswer_tmp:=AnsiLowerCase(In_StringAnswer);

  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';

  { ���� �������� ���� � ������ }
  IF POS(In_Param_tmp, In_StringAnswer_tmp)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param_tmp, In_StringAnswer_tmp)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { ���� ��������� ��� � ������, �� ���������� ��� � ����� }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ ��������� ���������� ���������� � ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " }
Function countParamFromString(In_StringAnswer:WideString):Word;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
begin
  { ����� ���������� ����� ����� ������ = }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  { ����� � ��������� }
  WHILE findChar=True DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False
          end
        ELSE
          begin
            countChar:=countChar+1;
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While
  Result:=countChar;
end;

{ ��������� ������������ ��������� �� ��� ����������� ������. ��� "��������_�����_1=100.00; ��������_�����_2=200.00; " ������ �������� = ��������_�����_2 }
Function paramNameFromString(In_StringAnswer:WideString; In_ParamNumber:Word):ShortString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { ��������� � posRAVNO ������� ����� "=" ��� �������� ��������� }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { ����� � ��������� }
  WHILE (findChar=True)AND(countChar<In_ParamNumber) DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False;
            posRAVNO:=0;
          end
        ELSE
          begin
            countChar:=countChar+1;
            posRAVNO:=posRAVNO+POS('=', subStrForFind);
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While

  { ��������� � ��������� "������-posRAVNO" }
  IF posRAVNO<>0
    THEN
      begin
        subStrForFind:=COPY(In_StringAnswer, 1, posRAVNO-1);
        posCurrent:=posRAVNO-1;
        Result:='';
        WHILE (posCurrent>=1)AND(COPY(subStrForFind, posCurrent, 1)<>' ')AND(COPY(subStrForFind, posCurrent, 1)<>';') DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent-1;
          end; // While
        { �������� ��� ��������� � ���������� �����������: 2_�������� ("��������_2"). ��������� �������� �������������� }
        posCurrent:=Length(Result);
        subStrForFind:=Result;
        Result:='';
        WHILE (posCurrent>=1) DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent-1;
          end; // While
      end
    ELSE
      begin
        Result:='';
      end;
end;

{ ��������� �������� ��������� �� ��� ����������� ������. ��� "��������_�����_1=100.00; ��������_�����_2=200.00; " ������ �������� = 200.00 }
Function paramValueFromString(In_StringAnswer:WideString; In_ParamNumber:Word):WideString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { ��������� � posRAVNO ������� ����� "=" ��� �������� ��������� }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { ����� � ��������� }
  WHILE (findChar=True)AND(countChar<In_ParamNumber) DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False;
            posRAVNO:=0;
          end
        ELSE
          begin
            countChar:=countChar+1;
            posRAVNO:=posRAVNO+POS('=', subStrForFind);
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While
  { ��������� � ��������� "(posRAVNO+1)-�����" }
  IF posRAVNO<>0
    THEN
      begin
        subStrForFind:=COPY(In_StringAnswer, posRAVNO+1, Length(In_StringAnswer)-posRAVNO );
        posCurrent:=1;
        Result:='';
        WHILE (posCurrent<=Length(subStrForFind))AND(COPY(subStrForFind, posCurrent, 1)<>';') DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent+1;
          end; // While
      end
    ELSE
      begin
        Result:='';
      end;
end;

{ ������� �� �������� ��������� 1234-9044951501 �������� ������ 1234 (��� In_ParamNumber=1) ��� ������ 9044951501 (��� In_ParamNumber=2) �������� }
Function getParamFromDoublePayment(In_DoubleAutData:ShortString; In_ParamNumber:Byte):ShortString;
var  autData, autData1, autData2:ShortString;
begin

  { � autData ������� ������� }
  autData:=StringReplace(In_DoubleAutData, ' ', '', [rfReplaceAll]);

  { ��������� autData �� autData1 � autData2 }
  IF (POS('-',autData)<>0)
    THEN
      begin
        { ����� �������� }
        autData2:=COPY(autData, POS('-',autData)+1, Length(autData)-POS('-',autData) );
        { ������ ��� ����������� � ���� ������NNNNN }
        autData1:=COPY(autData, 1, POS('-',autData)-1 );
      end
    ELSE
      begin
        { ����� �������� }
        autData2:='';
        { ������ ��� ����������� � ���� ������NNNNN }
        autData1:=autData;
      end; // If

  { ��������� }
  IF In_ParamNumber=1 THEN Result:=autData1 ELSE Result:=autData2;

end;

{ ����� ��������� ���������� ��� PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) ����������� " ; = # ���������� ������������� �������� ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - ���������� ������������. In_Mask_DeMask=DeMask - ���������� ��-������������ }
Function ps_paymGate_maskSymbol(In_String:WideString; In_Mask_DeMask:ShortString ):WideString;
begin
  { ���� ������ ������������ }
  IF In_Mask_DeMask='Mask'
    THEN
      begin
        { " -> &quot }
        In_String:=StringReplace(In_String, '"', '&quot', [rfReplaceAll] );
        { ; -> &quo4 }
        In_String:=StringReplace(In_String, ';', '&quo4', [rfReplaceAll] );
        { = -> &quou }
        In_String:=StringReplace(In_String, '=', 'quou', [rfReplaceAll] );
        { # -> &quo3 }
        In_String:=StringReplace(In_String, '#', '&quo3', [rfReplaceAll] );
      end; // If

  { ���� ������ ��-������������ }
  IF In_Mask_DeMask='DeMask'
    THEN
      begin
        { &quot -> "  }
        In_String:=StringReplace(In_String, '&quot', '"', [rfReplaceAll] );
        { &quo4 -> ;  }
        In_String:=StringReplace(In_String, '&quo4', ';', [rfReplaceAll] );
        { &quou -> =  }
        In_String:=StringReplace(In_String, 'quou', '=', [rfReplaceAll] );
        { &quo3 -> # }
        In_String:=StringReplace(In_String, '&quo3', '#', [rfReplaceAll] );
      end; // If
  { ��������� }
  Result:=In_String;
end;

{ ������� ���������� ��������� Ip ����� }
Function GetLocalIP: ShortString;
const WSVer = $101; var wsaData: TWSAData; P: PHostEnt; Buf: array [0..127] of Char;
begin
  Result:= '';
  if WSAStartup(WSVer, wsaData) = 0 then begin
    if GetHostName(@Buf, 128) = 0 then begin
      P := GetHostByName(@Buf);
      if P <> nil then Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

{ ������������ �������� ������ }
Function maskString(In_StringForMask:ShortString):ShortString;
var startPosMask, endPosMask, i:Word;
begin
  Result:='';
  { ������� ������ ������������ }
  startPosMask:= ((Length(In_StringForMask) Div 2) Div 2)+2;
  { ������� ��������� ������������ }
  endPosMask:= (Length(In_StringForMask) Div 2) + ((Length(In_StringForMask) Div 2) Div 2);
  FOR i:=1 TO Length(In_StringForMask) DO
    begin
      { ��������� � ��������� ������������? }
      IF (i>=startPosMask)AND(i<=endPosMask)
        THEN
          begin
            { ��������� }
            Result:=Result+'X';
          end
        ELSE
          begin
            Result:=Result+In_StringForMask[i];
          end; // If
    end; // For
end;

    { *** ����� ������� �������� �������� � ������� DLL *** }

    exports

{ *** ������ ������� �������������� �� Dll �������� � ������� *** }

// 1. ������� RoundCurrency ��������� ������������ �� �������� �� ���������� ���������� ������ ����� �������
RoundCurrency Name 'RoundCurrency',

// 2. ������� DosToWin ����������� Dos ��������� �������� ������ � ������� ��������� Windows
DosToWin Name 'DosToWin',

// 3. ������� WinToDos ����������� Windows ��������� �������� ������ � ������� ��������� Dos
WinToDos Name 'WinToDos',

// 4. �������������� ����������� ����� � ������� ����� (, -> .), ��������������� � ��������� ����
ChangeSeparator Name 'ChangeSeparator',

// 5. �������������� ����������� ����� � ������� ����� (. -> ,), ��������������� � ��������� ����
ChangeSeparator2 Name 'ChangeSeparator2',

// 6. ������������� ������ ������������ �����
LeftFixString Name 'LeftFixString',

// 7. ������������� ������ ������������ ������
RightFixString Name 'RightFixString',

// 8. ������������� ������ ������������ �� ������
CentrFixString Name 'CentrFixString',

// 9. �������������� ����� �� prn-�����
prnSum Name 'prnSum',

// 10. �������������� ������ '25 000,25' � ����� 25000,25
TrSum Name 'TrSum',

// 11. �������������� ��������� ���� "��.��.����" � ���������� ���� ���� Int
bnkDay Name 'bnkDay',

// 12. ������� ����������� ���� 01.01.2002 � ������ '01/01/2002'
DiaStrDate Name 'DiaStrDate',

// 13. ������� ����������� ���� 01.01.2002 � ������ '"01" ������ 2002 �.'
PropisStrDate Name 'PropisStrDate',

// 14. ������� ���������� � ������������ ������, ������� ������ ���������� ^
FindSeparator Name 'FindSeparator',

// 15. ������� ���������� � ������������ ������, ������� ������ ������������� �������
FindChar Name 'FindChar',

// 15+. ������� ���������� � ������������ ������, ������� ������ ������������� �������
FindCharWideString Name 'FindCharWideString',

FindCharWideString2 Name 'FindCharWideString2',

// 16. ������� ���������� � ������������ ������, ������� �������
FindSpace Name 'FindSpace',

{ ������� ����� ��������� ������� In_Char � ������ In_String }
countCharInString Name 'countCharInString',

// 17. ������� ����������� Win ������ 'Abcd' -> 'ABCD'
Upper Name 'Upper',

// 18. ������� ����������� Win ������ 'abcd' -> 'Abcd'
Proper Name 'Proper',

// 19. ������� ����������� Win ������ 'ABCD' -> 'abcd'
Lower Name 'Lower',

// 20. ������� ����������� ������ '1000,00' -> '1 000,00'
Divide1000 Name 'Divide1000',

// 21. ������� ���������� �������� � �������� ������ �� ini-�����; ���� ��� ini - 'INIFILE_NOT_FOUND'. ���� ��� ��������� - 'PARAMETR_NOT_FOUND'
paramFromIniFile Name 'paramFromIniFile',

paramFromIniFileWithOutMessDlg Name 'paramFromIniFileWithOutMessDlg',

paramFromIniFileWithOutMessDlg2 Name 'paramFromIniFileWithOutMessDlg2',

paramFromIniFileWithFullPath Name 'paramFromIniFileWithFullPath',

paramFromIniFileWithFullPathWithOutMessDlg Name 'paramFromIniFileWithFullPathWithOutMessDlg',

// 22. ������� ���� ini ���� � �������� � ���; ���� ��� ��������� - ������������ �������� ���������, ���� ��� - �� ��������� �������� 'INIFILE_NOT_FOUND' ��� 'PARAMETR_NOT_FOUND'
paramFoundFromIniFile Name 'paramFoundFromIniFile',

// 23. ������� ��������� ����� ������ ���� 1 �� ������� ���������� ������-> '0001'
beforZero Name 'beforZero',

// 24. ������������� ��������� �� 12-� ������ � �������� ������������ ������
ID12docFromJournal Name 'ID12docFromJournal',

// 25. �������������� ������ '01-01-05 01:01:01'
dateTimeToSec Name 'dateTimeToSec',

// 26. �������������� String � PChar
StrToPchar Name 'StrToPchar',

// 27. ��������� ������� � ��� ���� � ������ InFileName ������ InString � ��������� ������� ���� InLn='Ln'
ToLogFileWithName Name 'ToLogFileWithName',

// 27+. ��������� ������� � ��� ���� � ������ InFileName ������ InString � ��������� ������� ���� InLn='Ln'
ToLogFileWideStringWithName Name 'ToLogFileWideStringWithName',

// 27++.
ToLogFileWithFullName Name 'ToLogFileWithFullName',

ToLogFileWideStringWithFullName Name 'ToLogFileWideStringWithFullName',

// 28. ������� ����������� ������ ��������� � �������� �� ������� �������������� � www.beonline.ru
TranslitBeeLine Name 'TranslitBeeLine',

// 29. ������� ����������� ���� 01.01.2002 � ������ '01/01/2002'
formatMSSqlDate Name 'formatMSSqlDate',

// 30. ������� ����������� ������ � ������� ���� � ������� TTimeStamp '04-04-2007 15:22:11 +0300' � ��� TDateTime ( ������������� �������� ����� +0300 ���� �� ��������� )
StrFormatTimeStampToDateTime Name 'StrFormatTimeStampToDateTime',

// 31. ������� ����������� ������ � ������� ���� � ������� TTimeStamp '04-04-2007 15:22:11 +0300' � ������ '04.04.2007 15:22:11'  ( ������������� �������� ����� +0300 ���� �� ��������� )
StrTimeStampToStrDateTime Name 'StrTimeStampToStrDateTime',

// 32. ������� DateTimeToStrFormat ����������� ���� � �����  01.01.2007 1:02:00 � ������ '0101200710200'
DateTimeToStrFormat Name 'DateTimeToStrFormat',

decodeCurCodeToISO  Name 'decodeCurCodeToISO',

cardExpDate_To_Date Name 'cardExpDate_To_Date',

decodeTypeCard Name 'decodeTypeCard',

decodeTypeCardGPB Name 'decodeTypeCardGPB',

PCharToStr Name 'PCharToStr',

StrDateFormat1 Name 'StrDateFormat1',

StrDateFormat2 Name 'StrDateFormat2',

SummaPropis Name 'SummaPropis',

SummaPropis2 Name 'SummaPropis2',

StrDateFormat3 Name 'StrDateFormat3',

YearFromDate Name 'YearFromDate',

CryptDES Name 'CryptDES',

DeCryptDES Name 'DeCryptDES',

GenHashMD5 Name 'GenHashMD5',

WindowsCopyFile Name 'WindowsCopyFile',

GetTempPathSystem Name 'GetTempPathSystem',

GetCurrDir Name 'GetCurrDir',

getShortFileName Name 'getShortFileName',

getFilePath Name 'getFilePath',

getShortFileNameWithoutExt Name 'getShortFileNameWithoutExt',

StrDateFormat4 Name 'StrDateFormat4',

StrDateFormat5 Name 'StrDateFormat5',

StrDateFormat6 Name 'StrDateFormat6',

StrDateFormat7 Name 'StrDateFormat7',

VariableBetweenChars Name 'VariableBetweenChars',

VariableBetweenCharsWideString Name 'VariableBetweenCharsWideString',

VariableBetweenCharsWideString2 Name 'VariableBetweenCharsWideString2',

VariableBetweenCharsWideString3 Name 'VariableBetweenCharsWideString3',

StrFormatDateTimeITDToDateTime Name 'StrFormatDateTimeITDToDateTime',

StrFormatDateTimeITDToDate Name 'StrFormatDateTimeITDToDate',

DateTimeToStrFormatITDDateTime Name 'DateTimeToStrFormatITDDateTime',

Sign_RSA_MD5_hex_WideStr Name 'Sign_RSA_MD5_hex_WideStr',

Sign_RSA_MD5_hex_File Name 'Sign_RSA_MD5_hex_File',

mixingString Name 'mixingString',

StrToFloat2 Name 'StrToFloat2',

SumFormat Name 'SumFormat',

DateTimeToStrFormatSirenaDateTime Name 'DateTimeToStrFormatSirenaDateTime',

StrDateFormat8 Name 'StrDateFormat8',

StrDateFormat9 Name 'StrDateFormat9',

StrDateFormat10 Name 'StrDateFormat10',

RandomUserName Name 'RandomUserName',

RandomUserPassword Name 'RandomUserPassword',

RussianDayOfWeek Name 'RussianDayOfWeek',

RussianDayOfWeekFromDate Name 'RussianDayOfWeekFromDate',

daysOffBetweenDates Name 'daysOffBetweenDates',

{ ��������� ShortString: ��������� ��������� �� ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " - ������������ � ��������_�����_1 � ��������_�����_11 }
paramFromString Name 'paramFromString',

{ ��������� ���������� ���������� � ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " }
countParamFromString Name 'countParamFromString',

{ ��������� ������������ ��������� �� ��� ����������� ������. ��� "��������_�����_1=100.00; ��������_�����_2=200.00; " ������ �������� = ��������_�����_2 }
paramNameFromString Name 'paramNameFromString',

{ ��������� �������� ��������� �� ��� ����������� ������. ��� "��������_�����_1=100.00; ��������_�����_2=200.00; " ������ �������� = 200.00 }
paramValueFromString Name 'paramValueFromString',

{ ��������� WideString: ��������� ��������� �� ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " - ������������ � ��������_�����_1 � ��������_�����_11 }
paramFromString2 Name 'paramFromString2',

{ ��������� WideString, ������������ � ��������! }
paramFromString3 Name 'paramFromString3',

{ ���������� �������� ��������� � ������ "��������_�����_1=100.00; ��������_�����_2=200.00; " }
setParamFromString Name 'setParamFromString',

{ ������� ������! ������������ � �������� }
setParamFromString2 Name 'setParamFromString2',

getParamFromDoublePayment Name 'getParamFromDoublePayment',

{ ����� ��������� ���������� ��� PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) ����������� " ; = # ���������� ������������� �������� ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - ���������� ������������. In_Mask_DeMask=DeMask - ���������� ��-������������ }
ps_paymGate_maskSymbol Name 'ps_paymGate_maskSymbol',

{ ������� ���������� ��������� Ip ����� }
GetLocalIP Name 'GetLocalIP',

{ ������������ �������� ������ }
maskString Name 'maskString'

;

{ *** ����� ������� �������������� �� Dll �������� � ������� *** }

begin
{ *** ������ ����� ������������� Dll *** }
{ ���, ���������� � ����� ������������� ������������� ����������� ��� �������� Dll }



{ *** ����� ����� ������������� ���������� *** }
end.
