﻿
{************************************************************}
{                                                            }
{       Библиотека PS_Dll сожержит процедуры и функции       }
{       наиболее часто использующиеся в проектах             }
{                                                            }
{       ver. 1.4 28-04-2022                                  }
{                                                            }
{       Delphi Coding Style Guide bit.ly/3EQTgh8             }
{                                 bit.ly/396wwO8             }
{                                                            }
{************************************************************}

Library PS_Dll;

uses
  ShareMem, SysUtils, Classes, Des in 'Des.pas', psnMD5 in 'psnMD5.pas',
    ShellApi, Windows, libeay32 in 'libeay32.pas',
    WinSock { D7 Controls, Dialogs };


{ Функция RoundCurrency округляет передаваемое ей значение до указанного
  количества знаков после запятой }

function RoundCurrency(Value: Double; Accuracy: Byte): Double;
begin

  case Accuracy of
    0: RoundCurrency := Round(Value);
    1: RoundCurrency := Round((Value + 0.0001) * 10) / 10;
    2: RoundCurrency := Round((Value + 0.00001) * 100) / 100;
  else
    RoundCurrency := Value;
  end;

end;


{ Функция DosToWin преобразует кодировку строки из Dos CP866
  в кодировку Windows-1251 }

function DosToWin(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalString: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
          128..178: LocalString := LocalString + Chr(Ord(InString[I]) + 64);
          179: LocalString := LocalString + Chr(124);
          180: LocalString := LocalString + Chr(43);
          191: LocalString := LocalString + Chr(43);
          192: LocalString := LocalString + Chr(43);
          193: LocalString := LocalString + Chr(43);
          194: LocalString := LocalString + Chr(43);
          195: LocalString := LocalString + Chr(43);
          196: LocalString := LocalString + Chr(45);
          197: LocalString := LocalString + Chr(43);
          217: LocalString := LocalString + Chr(43);
          218: LocalString := LocalString + Chr(43);
          224..239: LocalString := LocalString + Chr(Ord(InString[I]) + 16);
      else
        LocalString := LocalString + InString[I];
      end;

    end;

  DosToWin := LocalString;

end;


{ Функция WinToDos преобразует кодировку строки из Windows-1251
  в кодировку Dos CP866 }

function WinToDos(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalString: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
          166: LocalString := LocalString + Chr(124);
          185: LocalString := LocalString + ' ';
          192..239: LocalString := LocalString + Chr(Ord(InString[I]) - 64);
          240..255: LocalString := LocalString + Chr(Ord(InString[I]) - 16);
      else
          LocalString := LocalString + InString[I];
      end;
    end;

  WinToDos := LocalString;
end;


{ Преобразование разделителя целой и дробной части (, -> .), представленного
  в строковом виде }

function ChangeSeparator  (InStringFloat: ShortString): ShortString;
var
  LocalString: ShortString;
begin

  if Pos(',' ,InStringFloat) <> 0
    then
      begin

        LocalString := Copy(InStringFloat, 1, Pos(',', InStringFloat) - 1) + '.'
          + COPY(InStringFloat, Pos(',', InStringFloat) + 1,
          Length(InStringFloat) - Pos(',' , InStringFloat));

        if (Length(LocalString) - Pos('.', LocalString)) = 1 then
          LocalString:=LocalString+'0';

        ChangeSeparator := LocalString;

      end
  else ChangeSeparator := InStringFloat + '.00';

end;


{ Преобразование разделителя целой и дробной части (. -> ,), представленного
  в строковом виде }

function ChangeSeparator2(InStringFloat: ShortString): ShortString;
var
  LocalString: ShortString;
begin

  if Pos('.', InStringFloat)<>0 then
      begin
        LocalString := Copy(InStringFloat, 1, Pos('.' ,InStringFloat) - 1)
          + ',' + COPY(InStringFloat, Pos('.' , InStringFloat) + 1,
          Length(InStringFloat) - Pos('.', InStringFloat));

        if (Length(LocalString) - Pos('.', LocalString)) = 1 then
          LocalString := LocalString + '0';

        ChangeSeparator2 := LocalString;

      end
  else ChangeSeparator2 := InStringFloat + ',00';

end;


{ Фиксированная строка, выравнивание влево }

function LeftFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    LeftFixString := Copy(Trim(InString), 1, InFixPosition)
  else LeftFixString := Trim(InString) + StringOfChar(' ', InFixPosition
    - Length(Trim(InString)));

end;


{ Фиксированная строка, выравнивание вправо }

function RightFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    RightFixString := Copy(Trim(InString), 1, InFixPosition)
  else RightFixString:=StringOfChar(' ', InFixPosition - Length(Trim(InString)))
    + Trim(InString);

end;


{ Фиксированная строка, выравнивание по центру }

function CentrFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  InString := Trim(InString);

  if Length(Trim(InString)) >= InFixPosition then
    CentrFixString := Copy(Trim(InString), 1, InFixPosition)
  else
    begin
      CentrFixString:=StringOfChar(' ', Trunc((InFixPosition
        - Length(Trim(InString))) / 2)) + Trim(InString)
        + StringOfChar(' ', InFixPosition
        - Trunc((InFixPosition - Length(Trim(InString)))/2));
    end;

end;


{ Преобразование суммы из prn-файла }

function PrnSum(InString: ShortString): ShortString;
var
    I: 0..50;
    TrSum: ShortString;
begin

  TrSum := '';

  for I := 1 to Length(InString) do
    begin
      if ((InString[I] <> ' ') and ((InString[I] = '0') or (InString[I] = '1')
        or (InString[I] = '2') or (InString[I] = '3') or (InString[I] = '4')
        or (InString[I] = '5') or (InString[I] = '6') or (InString[I] = '7')
        or (InString[I] = '8') or (InString[I]='9'))) then
        TrSum := TrSum + InString[I];
      if (InString[I] = '-') or (InString[I] = '.') or (InString[I] = ',') then
        TrSum:=TrSum + ',';
    end;

  prnSum:=TrSum;

end;


{ Преобразование строки '25 000,25' в число 25000,25 }

function TrSum(InString: ShortString): Double;
var
  I: 0..50;
  TrSumStr: ShortString;
begin

  TrSumStr := '';

  for I := 1 to Length(InString) do
    if ((InString[I] <> ' ') and ((InString[I] = ',') or (InString[I] = '0')
      or (InString[I] = '1') or (InString[I] = '2') or (InString[I] = '3')
      or (InString[I] = '4') or (InString[I] = '5') or (InString[I] = '6')
      or (InString[I] = '7') or (InString[I] = '8') or (InString[I] = '9'))) then
        TrSumStr := TrSumStr + InString[I];

  TrSum := StrToFloat(TrSumStr);

end;


{ Преобразование текстовой даты "ДД.ММ.ГГГГ" в банковский день типа Int }

function BnkDay(InValue: ShortString): Word;
var
  CountDate: Word;
  WorkindDate: TDate;
  YearVar, MonthVar, DayVar: Word;
begin

  CountDate := 1;

  DecodeDate(StrToDate(InValue), YearVar, MonthVar, DayVar);

  WorkindDate := StrToDate('01.01.' + IntToStr(YearVar));

  while WorkindDate < StrToDate(InValue) do
    begin
      WorkindDate := WorkindDate + 1;
      CountDate := CountDate + 1;
    end;

  BnkDay := CountDate;

end;


{ Функция преобразует дату 01.01.2002 в строку '01/01/2002' }

function DiaStrDate(InValue: TDate): ShortString;
begin

  DiaStrDate := Copy(DateToStr(InValue), 1, 2) + '/'
    + Copy(DateToStr(InValue), 4, 2) +'/' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция преобразует дату 01.01.2002 в строку '"01" января 2002 г.' }

function PropisStrDate(InValue: TDate): ShortString;
var
  PropisStrDateTmp: ShortString;
begin

  PropisStrDateTmp := '"' + Copy(DateToStr(InValue), 1, 2) + '"';

  case StrToInt(COPY(DateToStr(InValue), 4, 2)) of
      1: PropisStrDateTmp := PropisStrDateTmp + ' января ';
      2: PropisStrDateTmp := PropisStrDateTmp + ' февраля ';
      3: PropisStrDateTmp := PropisStrDateTmp + ' марта ';
      4: PropisStrDateTmp := PropisStrDateTmp + ' апреля ';
      5: PropisStrDateTmp := PropisStrDateTmp + ' мая ';
      6: PropisStrDateTmp := PropisStrDateTmp + ' июня ';
      7: PropisStrDateTmp := PropisStrDateTmp + ' июля ';
      8: PropisStrDateTmp := PropisStrDateTmp + ' августа ';
      9: PropisStrDateTmp := PropisStrDateTmp + ' сентября ';
      10: PropisStrDateTmp := PropisStrDateTmp + ' октября ';
      11: PropisStrDateTmp := PropisStrDateTmp + ' ноября ';
      12: PropisStrDateTmp := PropisStrDateTmp + ' декабря ';
     end;

  PropisStrDateTmp := PropisStrDateTmp + COPY(DateToStr(InValue), 7, 4) + ' г.';
  PropisStrDate := PropisStrDateTmp;

end;


{ Функция определяет в передаваемой строке, позицию номера сепаратора ^ }

function FindSeparator(InString: ShortString; NumberOfSeparator: Byte): Byte;
var
  I, CounterSeparatorVar: Byte;
begin

  FindSeparator := 0;
  CounterSeparatorVar := 0;

  for I := 1 to Length(InString) do
    begin

      if InString[I] = '^' then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
          begin
            FindSeparator := I;
            Exit;
          end;
    end;

end;


{ Функция определяет в передаваемой строке, позицию номера передаваемого символа }

function FindChar(InString: ShortString; InChar: Char; NumberOfSeparator: Byte): Byte;
var
  I, CounterSeparatorVar: Byte;
begin

  FindChar:=0;
  CounterSeparatorVar:=0;

  for I:=1 to Length(InString) do
    begin

      if Copy(InString, I, 1) = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
          begin
            FindChar := I;
            Exit;
          end;
    end;

end;


{ Функция определяет в передаваемой широкой строке, позицию номера передаваемого символа }

function FindCharWideString(InString: String; InChar: Char; NumberOfSeparator: Word): Word;
var
  I, CounterSeparatorVar: Word;
begin

  FindCharWideString := 0;
  CounterSeparatorVar := 0;

  for I:=1 to Length(InString) do
    begin
      if InString[I] = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
        begin
          FindCharWideString := I;
          Exit;
        end;
    end;

end;


{ Функция определяет в передаваемой широкой строке, позицию номера передаваемого символа }

function FindCharWideString2(InString: WideString; InChar: Char; NumberOfSeparator: Word): Longword;
var
  I: Longword;
  CounterSeparatorVar: Word;
begin

  FindCharWideString2:=0;
  CounterSeparatorVar:=0;

  for I := 1 to Length(InString) do
    begin

      if Copy(InString, I, 1) = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
        begin
          FindCharWideString2 := I;
          Exit;
        end;
    end;
end;


{ Функция определяет в передаваемой строке, позицию пробела }

function FindSpace(InString: ShortString; NumberOfSpace: Byte): Byte;
var
  I, CounterSpaceVar: Byte;
begin

  FindSpace := 0;
  CounterSpaceVar := 0;

  for I := 1 to Length(InString) do
    begin

      if InString[I] = ' ' then
        CounterSpaceVar := CounterSpaceVar + 1;

      if (CounterSpaceVar = NumberOfSpace) then
        begin
          FindSpace := I;
          Exit;
        end;

    end;

end;


{ Подсчет числа вхождений символа InChar в строку InString }

function countCharInString(InString: WideString; InChar: ShortString): Word;
var InStringTmp: WideString;
    Count: Word;
begin

  Count := 0;
  InStringTmp := InString;

  while Pos(InChar, InStringTmp) <> 0 do
    begin
      Count := Count + 1;
      InStringTmp := Copy(InStringTmp, Pos(InChar, InStringTmp) + 1,
        Length(InStringTmp) - Pos(InChar, InStringTmp));
    end;

  Result := Count;

end;


{ Функция преобразует Win строку 'Abcd' -> 'ABCD' }

function Upper(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
        97..122: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
        184: LocalStr := LocalStr + Chr(Ord(InString[I]) - 16);
        224..255: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
      else
        LocalStr := LocalStr + InString[I];
      end;

    end;

  Upper := LocalStr;

end;

// ---- Waiting Coding Style ---

// 18. Функция преобразует Win строку 'abcd' -> 'Abcd'
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

// 19. Функция преобразует Win строку 'ABCD' -> 'abcd'
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

// 20. Функция преобразует строку '1000,00' -> '1 000,00'
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

// 21. Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
Function paramFromIniFile(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        { D7 MessageDlg('Не найден файл '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+'!', mtError, [mbOk],0); }
      end;
  IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN { D7 MessageDlg('В файле '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+' не найден параметр '+Trim(inParam)+'!', mtError, [mbOk],0); }
  paramFromIniFile:=tmp_paramFromIniFile;
end;

// 21++. Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
Function paramFromIniFileWithOutMessDlg(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        //MessageDlg('Не найден файл '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+'!', mtError, [mbOk],0);
      end;
  // IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('В файле '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+' не найден параметр '+Trim(inParam)+'!', mtError, [mbOk],0);

  paramFromIniFileWithOutMessDlg:=tmp_paramFromIniFile;

end;

{ 21+++. В отличие от paramFromIniFileWithOutMessDlg - результат WideString }
Function paramFromIniFileWithOutMessDlg2(inIniFile:ShortString; inParam:ShortString):WideString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:WideString;
    StrokaVar:WideString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
      end;

  paramFromIniFileWithOutMessDlg2:=tmp_paramFromIniFile;

end;


// 21+. Тоже самое, но имя к инишнику-полное - Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
Function paramFromIniFileWithFullPath(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        { D7 MessageDlg('Не найден файл '+inIniFile+'!', mtError, [mbOk],0); }
      end;
  IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN { D7 MessageDlg('В файле '+ExtractFilePath(inIniFile)+' не найден параметр '+Trim(inParam)+'!', mtError, [mbOk],0); }
  paramFromIniFileWithFullPath:=tmp_paramFromIniFile;
end;

// 21++. Тоже самое, но имя к инишнику-полное - Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
// без MessageDlg
Function paramFromIniFileWithFullPathWithOutMessDlg(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
        // MessageDlg('Не найден файл '+inIniFile+'!', mtError, [mbOk],0);
      end;
  // IF tmp_paramFromIniFile='PARAMETR_NOT_FOUND' THEN MessageDlg('В файле '+ExtractFilePath(inIniFile)+' не найден параметр '+Trim(inParam)+'!', mtError, [mbOk],0);

  paramFromIniFileWithFullPathWithOutMessDlg:=tmp_paramFromIniFile;

end;


// 22. Функция ищет ini файл и параметр в нем; Если все нормально - возвращается значение параметра, если нет - то заначение функциий 'INIFILE_NOT_FOUND' или 'PARAMETR_NOT_FOUND'
Function paramFoundFromIniFile(inIniFile:ShortString; inParam:ShortString):ShortString;
var iniFileVar:Textfile;
    tmp_paramFromIniFile:String[255];
    StrokaVar:ANSIString;
begin
  // Параметр не найден
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
        // Если инишника нет
        tmp_paramFromIniFile:='INIFILE_NOT_FOUND';
      end;
  paramFoundFromIniFile:=tmp_paramFromIniFile;
end;

// 23. Функция добавляет перед числом нули 1 до нужного количества знаков-> '0001'
Function beforZero(in_value:Integer; in_length:Word):ShortString;
var i:Word;
    string_0:ShortString;
begin
  string_0:='';
  FOR i:=1 TO (in_length - Length(IntToStr(in_value))) DO string_0:=string_0+'0';
  beforZero:=string_0+IntToStr(in_value);
end;

// 24. Автонумерация документа из 12-х знаков с ведением электронного жунала
Function ID12docFromJournal(In_Journal:ShortString; In_NameDoc:ShortString):Word;
var txtJournal:TextFile; StrokaVar:ShortString; tmpIDdoc:Word;
begin
  // Открываем журнал для чтения, если он есть, иначе tmpIDdoc:=0;
  tmpIDdoc:=0;
  IF FileExists(ExtractFilePath(ParamStr(0))+In_Journal)=True
    THEN
      begin
        AssignFile(txtJournal, ExtractFilePath(ParamStr(0))+In_Journal);
        Reset(txtJournal);
        WHILE EOF(txtJournal)=false DO
          begin
            Readln(txtJournal, StrokaVar);
            // Найти в журнале самый последний номер записи
            IF ((COPY(StrokaVar, 1, 1)='0')or(COPY(StrokaVar, 1, 1)='1')or(COPY(StrokaVar, 1, 1)='2')or(COPY(StrokaVar, 1, 1)='3')or(COPY(StrokaVar, 1, 1)='4')or(COPY(StrokaVar, 1, 1)='5')or(COPY(StrokaVar, 1, 1)='6')or(COPY(StrokaVar, 1, 1)='7')or(COPY(StrokaVar, 1, 1)='8')or(COPY(StrokaVar, 1, 1)='9'))
              THEN tmpIDdoc:=StrToInt(Trim(COPY(StrokaVar, 1, 12)));
          end;  // While
        CloseFile(txtJournal);
      end; // If
  // Если номер из журнала больше 999999999999
  IF tmpIDdoc=999999999999 THEN tmpIDdoc:=1 ELSE tmpIDdoc:=tmpIDdoc+1;
  // Открываем журнал для записи
  AssignFile(txtJournal, ExtractFilePath(ParamStr(0))+In_Journal);
  IF FileExists(ExtractFilePath(ParamStr(0))+In_Journal)=True
    THEN Append(txtJournal)
    ELSE
      begin
        ReWrite(txtJournal);
        WriteLn(txtJournal, 'Филиал АБ "Газпромбанк" (ЗАО) в г.Белоярский');
        WriteLn(txtJournal, 'Отдел Банковских карт');
        WriteLn(txtJournal, ' ');
        WriteLn(txtJournal, 'Электронный журнал регистрации документов');
        WriteLn(txtJournal, 'Начат: '+DateToStr(Now));
        WriteLn(txtJournal, '------------------------------------------------------------------------------------------');
        WriteLn(txtJournal, '      #     |   Дата   |                        Примечание                               |');
        WriteLn(txtJournal, '------------------------------------------------------------------------------------------');
      end;
  WriteLn(txtJournal, LeftFixString(IntToStr(tmpIDdoc),12)+'|'+DateToStr(Now)+'|'+DosToWin(In_NameDoc) );
  CloseFile(txtJournal);
  // Результат
  ID12docFromJournal:=tmpIDdoc;
end;

// 25. Преобразование Строки в Integer
Function dateTimeToSec(in_value_str:ShortString):Integer;
begin
  Result:=Round((StrToDate(COPY(in_value_str,1,2)+'.'+COPY(in_value_str,4,2)+'.20'+COPY(in_value_str,7,2))-StrToDate('01.01.2000')))*86400+
  StrToInt(COPY(in_value_str,16,2))+
  StrToInt(COPY(in_value_str,13,2))*60+
  StrToInt(COPY(in_value_str,10,2))*3600;
end;


// 26. Преобразование String в PChar
Function StrToPchar(In_string:string):Pchar;
begin
  In_string:=In_string+#0;
  result:=StrPCopy(@In_string[1], In_string);
end;

// 27. Процедура выводит в лог файл с именем InFileName строку InString с переводом каретки если InLn='Ln'
Procedure ToLogFileWithName(InFileName : shortString; InString : shortString; InLn : shortString);
var LogFile:TextFile;
begin

  { Обработка ошибок:
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
    // Открыть файл с протоколом работы системы
    IF FileExists(ExtractFilePath(ParamStr(0))+Trim(InFileName))=True THEN Append(LogFile) ELSE ReWrite(LogFile);
    // Занести строку
    IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
    // Закрыть файл с протоколом работы системы
    CloseFile(LogFile);
  except
    {on E: Exception do WriteLn(E.Message);}
  end;

end;

// 27+. Процедура выводит в лог файл с Широкой строкой с именем InFileName строку InString с переводом каретки если InLn='Ln'
Procedure ToLogFileWideStringWithName(InFileName : shortString; InString : String; InLn : shortString);
var LogFile:TextFile;
begin

  { Обработка ошибок:
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
    // Открыть файл с протоколом работы системы
    IF FileExists(ExtractFilePath(ParamStr(0))+Trim(InFileName))=True THEN Append(LogFile) ELSE ReWrite(LogFile);
    // Занести строку
    IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
    // Закрыть файл с протоколом работы системы
    CloseFile(LogFile);
  except
    {on E: Exception do WriteLn(E.Message);}
  end;

end;

// 27++ Полный путь к лог-файлу
Procedure ToLogFileWithFullName(InFileName : shortString; InString : shortString; InLn : shortString);
var LogFile:TextFile;
begin
  AssignFile(LogFile, InFileName);
  // Открыть файл с протоколом работы системы
  IF FileExists(InFileName)=True THEN Append(LogFile) ELSE ReWrite(LogFile);
  // Занести строку
  IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
  // Закрыть файл с протоколом работы системы
  CloseFile(LogFile);
end;

// 27+++ Полный путь к лог-файлу (WideString)
Procedure ToLogFileWideStringWithFullName(InFileName : shortString; InString : WideString; InLn : shortString);
var LogFile:TextFile;
begin
  AssignFile(LogFile, InFileName);
  // Открыть файл с протоколом работы системы
  IF FileExists(InFileName)=True THEN Append(LogFile) ELSE ReWrite(LogFile);
  // Занести строку
  IF InLn='Ln' THEN WriteLn(LogFile, DateToStr(Now)+' '+TimeToStr(Now)+': '+InString) ELSE Write(LogFile, ' '+InString);
  // Закрыть файл с протоколом работы системы
  CloseFile(LogFile);
end;


// 28. Функция преобразует строку Кириллицы в Латиницу по таблице транслитерации с www.beonline.ru
Function TranslitBeeLine(in_string:ShortString):ShortString;
var i:1..1000;
    localStr:String;
begin
  FOR i:=1 TO Length(in_string) DO
    begin
      CASE in_string[i] OF
           'Й' : localStr:=localStr + 'J'; 'Ц' : localStr:=localStr + 'TS'; 'У' : localStr:=localStr + 'U'; 'К' : localStr:=localStr + 'K';
           'Е' : localStr:=localStr + 'E'; 'Н' : localStr:=localStr + 'N'; 'Г' : localStr:=localStr + 'G'; 'Ш' : localStr:=localStr + 'SH';
           'Щ' : localStr:=localStr + 'SCH'; 'З' : localStr:=localStr + 'Z'; 'Х' : localStr:=localStr + 'H'; 'Ъ' : localStr:=localStr + '"';
           'Ф' : localStr:=localStr + 'F'; 'Ы' : localStr:=localStr + 'Y'; 'В' : localStr:=localStr + 'V'; 'А' : localStr:=localStr + 'A';
           'П' : localStr:=localStr + 'P'; 'Р' : localStr:=localStr + 'R'; 'О' : localStr:=localStr + 'O'; 'Л' : localStr:=localStr + 'L';
           'Д' : localStr:=localStr + 'D'; 'Ж' : localStr:=localStr + 'ZH'; 'Э' : localStr:=localStr + 'E'; 'Я' : localStr:=localStr + 'YA';
           'Ч' : localStr:=localStr + 'CH'; 'С' : localStr:=localStr + 'S'; 'М' : localStr:=localStr + 'M'; 'И' : localStr:=localStr + 'I';
           'Т' : localStr:=localStr + 'T'; 'Ь' : localStr:=localStr + '"'; 'Б' : localStr:=localStr + 'B'; 'Ю' : localStr:=localStr + 'YU';
           //
           'й' : localStr:=localStr + 'j'; 'ц' : localStr:=localStr + 'ts'; 'у' : localStr:=localStr + 'u'; 'к' : localStr:=localStr + 'k';
           'е' : localStr:=localStr + 'e'; 'н' : localStr:=localStr + 'n'; 'г' : localStr:=localStr + 'g'; 'ш' : localStr:=localStr + 'sh';
           'щ' : localStr:=localStr + 'sch'; 'з' : localStr:=localStr + 'z'; 'х' : localStr:=localStr + 'h'; 'ъ' : localStr:=localStr + '"';
           'ф' : localStr:=localStr + 'f'; 'ы' : localStr:=localStr + 'y'; 'в' : localStr:=localStr + 'v'; 'а' : localStr:=localStr + 'a';
           'п' : localStr:=localStr + 'p'; 'р' : localStr:=localStr + 'r'; 'о' : localStr:=localStr + 'o'; 'л' : localStr:=localStr + 'l';
           'д' : localStr:=localStr + 'd'; 'ж' : localStr:=localStr + 'zh'; 'э' : localStr:=localStr + 'e'; 'я' : localStr:=localStr + 'ya';
           'ч' : localStr:=localStr + 'ch'; 'с' : localStr:=localStr + 's'; 'м' : localStr:=localStr + 'm'; 'и' : localStr:=localStr + 'i';
           'т' : localStr:=localStr + 't'; 'ь' : localStr:=localStr + '"'; 'б' : localStr:=localStr + 'b'; 'ю' : localStr:=localStr + 'yu';
        ELSE
          localStr:=localStr+in_string[i];
      end; // Case
    end;// begin
  TranslitBeeLine:=localStr;
end;

// 29. Функция преобразует дату 06.05.2006 (06 мая 2006) в строку формата MS SQL '05.06.2006'
//     06.05.2006 10:01:05
Function formatMSSqlDate(in_value:TDate):ShortString;
begin
  formatMSSqlDate:=COPY(DateToStr(in_value),4,2)+'.'+COPY(DateToStr(in_value),1,2)+'.'+COPY(DateToStr(in_value),7,4);
end;

// 30. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в тип TDateTime ( корректировку часового пояса +0300 пока не учитываем )
Function StrFormatTimeStampToDateTime(In_StrFormatTimeStamp:ShortString):TDateTime;
begin
  StrFormatTimeStampToDateTime:=StrToDateTime(COPY(In_StrFormatTimeStamp,1,2)+'.'+COPY(In_StrFormatTimeStamp,4,2)+'.'+COPY(In_StrFormatTimeStamp,7,4)+'.'+' '+COPY(In_StrFormatTimeStamp,12,8));
end;

// 31. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в строку '04.04.2007 15:22:11'  ( корректировку часового пояса +0300 пока не учитываем )
Function StrTimeStampToStrDateTime(In_StrFormatTimeStamp:ShortString):ShortString;
begin
  StrTimeStampToStrDateTime:=COPY(In_StrFormatTimeStamp,1,2)+'.'+COPY(In_StrFormatTimeStamp,4,2)+'.'+COPY(In_StrFormatTimeStamp,7,4)+'.'+' '+COPY(In_StrFormatTimeStamp,12,8);
end;

// 32. Функция DateTimeToStrFormat преобразует дату и время  01.01.2007 1:02:00 в строку '0101200710200'
Function DateTimeToStrFormat(In_DateTime:TDateTime):ShortString;
var DateTimeToStrFormatVar:ShortString;
begin
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStr(In_DateTime), ' ', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStrFormatVar, '.', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar:=StringReplace(DateTimeToStrFormatVar, ':', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormat:=DateTimeToStrFormatVar;
end;

// 33. Функция преобразует код валюты 810 в ISO: "RUR"
Function decodeCurCodeToISO(In_CurrCode:Word):ShortString;
begin
  case In_CurrCode of
    0   : decodeCurCodeToISO:='RUR';
    4   : decodeCurCodeToISO:='AFA';  //    Афгани
    8   : decodeCurCodeToISO:='ALL';  //    Лек
    12  : decodeCurCodeToISO:='DZD';  //    Алжирский динар
    20  : decodeCurCodeToISO:='ADP';  //    Андорская песета
    31  : decodeCurCodeToISO:='AZM';  //    Азербайджанский манат
    32  : decodeCurCodeToISO:='ARS';  //    Аргентинское песо
    36  : decodeCurCodeToISO:='AUD';  //    Австралийский доллар
    40  : decodeCurCodeToISO:='ATS';  //    Шиллинг
    44  : decodeCurCodeToISO:='BSD';  //    Багамский доллар
    48  : decodeCurCodeToISO:='BHD';  //    Бахрейнский динар
    50  : decodeCurCodeToISO:='BDT';  //    Така
    51  : decodeCurCodeToISO:='AMD';  //    Армянский драм
    52  : decodeCurCodeToISO:='BBD';  //    Барбадосский доллар
    56  : decodeCurCodeToISO:='BEF';  //    Бельгийский франк
    60  : decodeCurCodeToISO:='BMD';  //    Бермудский доллар
    64  : decodeCurCodeToISO:='BTN';  //    Нгултрум
    68  : decodeCurCodeToISO:='BOB';  //    Боливиано
    72  : decodeCurCodeToISO:='BWP';  //    Пула
    84  : decodeCurCodeToISO:='BZD';  //    Белизский доллар
    90  : decodeCurCodeToISO:='SBD';  //    Доллар Соломоновых
    96  : decodeCurCodeToISO:='BND';  //    Брунейский доллар
    100 : decodeCurCodeToISO:='BGL';  //    Лев
    104 : decodeCurCodeToISO:='MMK';  //    Кьят
    108 : decodeCurCodeToISO:='BIF';  //    Бурундийский франк
    116 : decodeCurCodeToISO:='KHR';  //    Риель
    124 : decodeCurCodeToISO:='CAD';  //    Канадский доллар
    132 : decodeCurCodeToISO:='CVE';  //    Эскудо Кабо - Верде
    136 : decodeCurCodeToISO:='KYD';  //    Доллар Каймановых
    144 : decodeCurCodeToISO:='LKR';  //    Шри - Ланкийская рупия
    152 : decodeCurCodeToISO:='CLP';  //    Чилийское песо
    156 : decodeCurCodeToISO:='CNY';  //    Юань Ренминби
    170 : decodeCurCodeToISO:='COP';  //    Колумбийское песо
    174 : decodeCurCodeToISO:='KMF';  //    Франк Коморских
    188 : decodeCurCodeToISO:='CRC';  //    Костариканский колон
    191 : decodeCurCodeToISO:='HRK';  //    Куна
    192 : decodeCurCodeToISO:='CUP';  //    Кубинское песо
    196 : decodeCurCodeToISO:='CYP';  //    Кипрский фунт
    203 : decodeCurCodeToISO:='CZK';  //    Чешская крона
    208 : decodeCurCodeToISO:='DKK';  //    Датская крона
    214 : decodeCurCodeToISO:='DOP';  //    Доминиканское песо
    218 : decodeCurCodeToISO:='ECS';  //    Сукре
    222 : decodeCurCodeToISO:='SVC';  //    Сальвадорский колон
    230 : decodeCurCodeToISO:='ETB';  //    Эфиопский быр
    232 : decodeCurCodeToISO:='ERN';  //    Накфа
    233 : decodeCurCodeToISO:='EEK';  //    Крона
    238 : decodeCurCodeToISO:='FKP';  //    Фунт Фолклендских
    242 : decodeCurCodeToISO:='FJD';  //    Доллар Фиджи
    246 : decodeCurCodeToISO:='FIM';  //    Марка
    250 : decodeCurCodeToISO:='FRF';  //    Французский франк
    262 : decodeCurCodeToISO:='DJF';  //    Франк Джибути
    270 : decodeCurCodeToISO:='GMD';  //    Даласи
    276 : decodeCurCodeToISO:='DEM';  //    Немецкая марка
    288 : decodeCurCodeToISO:='GHC';  //    Седи
    292 : decodeCurCodeToISO:='GIP';  //    Гибралтарский фунт
    300 : decodeCurCodeToISO:='GRD';  //    Драхма
    320 : decodeCurCodeToISO:='GTQ';  //    Кетсаль
    324 : decodeCurCodeToISO:='GNF';  //    Гвинейский франк
    328 : decodeCurCodeToISO:='GYD';  //    Гайанский доллар
    332 : decodeCurCodeToISO:='HTG';  //    Гурд
    340 : decodeCurCodeToISO:='HNL';  //    Лемпира
    344 : decodeCurCodeToISO:='HKD';  //    Гонконгский доллар
    348 : decodeCurCodeToISO:='HUF';  //    Форинт
    352 : decodeCurCodeToISO:='ISK';  //    Исландская крона
    356 : decodeCurCodeToISO:='INR';  //    Индийская рупия
    360 : decodeCurCodeToISO:='IDR';  //    Рупия
    364 : decodeCurCodeToISO:='IRR';  //    Иранский риал
    368 : decodeCurCodeToISO:='IQD';  //    Иракский динар
    372 : decodeCurCodeToISO:='IEP';  //    Ирландский фунт
    376 : decodeCurCodeToISO:='ILS';  //    Новый израильский
    380 : decodeCurCodeToISO:='ITL';  //    Итальянская лира
    388 : decodeCurCodeToISO:='JMD';  //    Ямайский доллар
    392 : decodeCurCodeToISO:='JPY';  //    Йена
    398 : decodeCurCodeToISO:='KZT';  //    Тенге
    400 : decodeCurCodeToISO:='JOD';  //    Иорданский динар
    404 : decodeCurCodeToISO:='KES';  //    Кенийский шиллинг
    408 : decodeCurCodeToISO:='KPW';  //    Северо - корейская вона
    410 : decodeCurCodeToISO:='KRW';  //    Вона
    414 : decodeCurCodeToISO:='KWD';  //    Кувейтский динар
    417 : decodeCurCodeToISO:='KGS';  //    Сом
    418 : decodeCurCodeToISO:='LAK';  //    Кип
    422 : decodeCurCodeToISO:='LBP';  //    Ливанский фунт
    426 : decodeCurCodeToISO:='LSL';  //    Лоти
    428 : decodeCurCodeToISO:='LVL';  //    Латвийский лат
    430 : decodeCurCodeToISO:='LRD';  //    Либерийский доллар
    434 : decodeCurCodeToISO:='LYD';  //    Ливийский динар
    440 : decodeCurCodeToISO:='LTL';  //    Литовский лит
    442 : decodeCurCodeToISO:='LUF';  //    Люксембургский франк
    446 : decodeCurCodeToISO:='MOP';  //    Патака
    450 : decodeCurCodeToISO:='MGF';  //    Малагасийский франк
    454 : decodeCurCodeToISO:='MWK';  //    Квача
    458 : decodeCurCodeToISO:='MYR';  //    Малайзийский ринггит
    462 : decodeCurCodeToISO:='MVR';  //    Руфия
    470 : decodeCurCodeToISO:='MTL';  //    Мальтийская лира
    478 : decodeCurCodeToISO:='MRO';  //    Угия
    480 : decodeCurCodeToISO:='MUR';  //    Маврикийская рупия
    484 : decodeCurCodeToISO:='MXN';  //    Мексиканское песо
    496 : decodeCurCodeToISO:='MNT';  //    Тугрик
    498 : decodeCurCodeToISO:='MDL';  //    Молдавский лей
    504 : decodeCurCodeToISO:='MAD';  //    Марокканский дирхам
    508 : decodeCurCodeToISO:='MZM';  //    Метикал
    512 : decodeCurCodeToISO:='OMR';  //    Оманский риал
    516 : decodeCurCodeToISO:='NAD';  //    Доллар Намибии
    524 : decodeCurCodeToISO:='NPR';  //    Непальская рупия
    528 : decodeCurCodeToISO:='NLG';  //    Нидерландский гульден
    532 : decodeCurCodeToISO:='ANG';  //    Нидерландский
    533 : decodeCurCodeToISO:='AWG';  //    Арубанский гульден
    548 : decodeCurCodeToISO:='VUV';  //    Вату
    554 : decodeCurCodeToISO:='NZD';  //    Новозеландский доллар
    558 : decodeCurCodeToISO:='NIO';  //    Золотая кордоба
    566 : decodeCurCodeToISO:='NGN';  //    Найра
    578 : decodeCurCodeToISO:='NOK';  //    Норвежская крона
    586 : decodeCurCodeToISO:='PKR';  //    Пакистанская рупия
    590 : decodeCurCodeToISO:='PAB';  //    Бальбоа
    598 : decodeCurCodeToISO:='PGK';  //    Кина
    600 : decodeCurCodeToISO:='PYG';  //    Гуарани
    604 : decodeCurCodeToISO:='PEN';  //    Новый соль
    608 : decodeCurCodeToISO:='PHP';  //    Филиппинское песо
    620 : decodeCurCodeToISO:='PTE';  //    Португальское эскудо
    624 : decodeCurCodeToISO:='GWP';  //    Песо Гвинеи - Бисау
    626 : decodeCurCodeToISO:='TPE';  //    Тиморское эскудо
    634 : decodeCurCodeToISO:='QAR';  //    Катарский риал
    642 : decodeCurCodeToISO:='ROL';  //    Лей
    643 : decodeCurCodeToISO:='RUB';  //    Российский рубль
    646 : decodeCurCodeToISO:='RWF';  //    Франк Руанды
    654 : decodeCurCodeToISO:='SHP';  //    Фунт Острова Святой
    678 : decodeCurCodeToISO:='STD';  //    Добра
    682 : decodeCurCodeToISO:='SAR';  //    Саудовский риял
    690 : decodeCurCodeToISO:='SCR';  //    Сейшельская рупия
    694 : decodeCurCodeToISO:='SLL';  //    Леоне
    702 : decodeCurCodeToISO:='SGD';  //    Сингапурский доллар
    703 : decodeCurCodeToISO:='SKK';  //    Словацкая крона
    704 : decodeCurCodeToISO:='VND';  //    Донг
    705 : decodeCurCodeToISO:='SIT';  //    Толар
    706 : decodeCurCodeToISO:='SOS';  //    Сомалийский шиллинг
    710 : decodeCurCodeToISO:='ZAR';  //    Рэнд
    716 : decodeCurCodeToISO:='ZWD';  //    Доллар Зимбабве
    724 : decodeCurCodeToISO:='ESP';  //    Испанская песета
    736 : decodeCurCodeToISO:='SDD';  //    Суданский динар
    740 : decodeCurCodeToISO:='SRG';  //    Суринамский гульден
    748 : decodeCurCodeToISO:='SZL';  //    Лилангени
    752 : decodeCurCodeToISO:='SEK';  //    Шведская крона
    756 : decodeCurCodeToISO:='CHF';  //    Швейцарский франк
    760 : decodeCurCodeToISO:='SYP';  //    Сирийский фунт
    764 : decodeCurCodeToISO:='THB';  //    Бат
    776 : decodeCurCodeToISO:='TOP';  //    Паанга
    780 : decodeCurCodeToISO:='TTD';  //    Доллар Тринидада и
    784 : decodeCurCodeToISO:='AED';  //    Дирхам (ОАЭ)
    788 : decodeCurCodeToISO:='TND';  //    Тунисский динар
    792 : decodeCurCodeToISO:='TRL';  //    Турецкая лира
    795 : decodeCurCodeToISO:='TMM';  //    Манат
    800 : decodeCurCodeToISO:='UGX';  //    Угандийский шиллинг
    807 : decodeCurCodeToISO:='MKD';  //    Динар
    810 : decodeCurCodeToISO:='RUR';  //    Российский рубль
    818 : decodeCurCodeToISO:='EGP';  //    Египетский фунт
    826 : decodeCurCodeToISO:='GBP';  //    Фунт стерлингов
    834 : decodeCurCodeToISO:='TZS';  //    Танзанийский шиллинг
    840 : decodeCurCodeToISO:='USD';  //    Доллар США
    858 : decodeCurCodeToISO:='UYU';  //    Уругвайское песо
    860 : decodeCurCodeToISO:='UZS';  //    Узбекский сум
    862 : decodeCurCodeToISO:='VEB';  //    Боливар
    882 : decodeCurCodeToISO:='WST';  //    Тала
    886 : decodeCurCodeToISO:='YER';  //    Йеменский риал
    891 : decodeCurCodeToISO:='YUM';  //    Новый динар
    894 : decodeCurCodeToISO:='ZMK';  //    Квача (замбийская)
    901 : decodeCurCodeToISO:='TWD';  //    Новый тайваньский
    950 : decodeCurCodeToISO:='XAF';  //    Франк КФА ВЕАС
    951 : decodeCurCodeToISO:='XCD';  //    Восточно - карибский
    952 : decodeCurCodeToISO:='XOF';  //    Франк КФА ВСЕАО
    953 : decodeCurCodeToISO:='XPF';  //    Франк КФП
    960 : decodeCurCodeToISO:='XDR';  //    СДР (специальные права
    972 : decodeCurCodeToISO:='TJS';  //    Сомони
    973 : decodeCurCodeToISO:='AOA';  //    Кванза
    974 : decodeCurCodeToISO:='BYR';  //    Белорусский рубль
    975 : decodeCurCodeToISO:='BGN';  //    Болгарский лев
    976 : decodeCurCodeToISO:='CDF';  //    Конголезский франк
    977 : decodeCurCodeToISO:='ВАМ';  //    Конвертируемая марка
    978 : decodeCurCodeToISO:='EUR';  //    Евро
    980 : decodeCurCodeToISO:='UAH';  //    Гривна
    981 : decodeCurCodeToISO:='GEL';  //    Лари
    985 : decodeCurCodeToISO:='PLN';  //    Злотый
    986 : decodeCurCodeToISO:='BRL';  //    Бразильский реал
      end;
end;

// 34. Преобразование строки "01-05" в дату 31.01.2005
Function cardExpDate_To_Date(In_cardExpDate:ShortString):TDate;
var Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(StrToDate('01.'+COPY(In_cardExpDate,1,2)+'.20'+COPY(In_cardExpDate,4,2)), Year, Month, Day);
  IF Month=12
    THEN cardExpDate_To_Date:=StrToDate('01.'+IntToStr(1)+'.'+ IntToStr(StrToInt('20'+COPY(In_cardExpDate,4,2))+1) )-1
    ELSE cardExpDate_To_Date:=StrToDate('01.'+IntToStr(Month+1)+'.20'+COPY(In_cardExpDate,4,2))-1;
end;

// 35. Преобразование номера карты по первым 9-ти цифрам в тип карты (филиал)
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
  // Пенсионная карта
  IF (COPY(In_CardNumber, 1, 9)='487417415') THEN decodeTypeCard_tmp:='VISA Electron Пенсионная';
  IF (COPY(In_CardNumber, 1, 9)='487415415') THEN decodeTypeCard_tmp:='VISA Classic Пенсионная';
  IF (COPY(In_CardNumber, 1, 9)='487416415') THEN decodeTypeCard_tmp:='VISA Gold Пенсионная';

  decodeTypeCard:=decodeTypeCard_tmp;
end;

// 35.+ Преобразование номера карты по первым 6-ти цифрам в тип карты (Газпромбанк)
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


// 36. Преобразование PChar в Str
Function PCharToStr(P:Pchar) :String;
begin
  Result:=P;
end;

// 37. Функция преобразует дату 01.01.2002 в строку '01/01/2002'
Function StrDateFormat1(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat1:=COPY(DateToStr(in_value),1,2)+'/'+COPY(DateToStr(in_value),4,2)+'/'+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat1:=COPY(DateToStr(in_value),1,2)+'/'+COPY(DateToStr(in_value),4,2)+'/'+COPY(DateToStr(in_value),7,4);
end;

// 38. Функция преобразует дату 01.01.2002 в строку '01-01-2002'
Function StrDateFormat2(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat2:=COPY(DateToStr(in_value),1,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat2:=COPY(DateToStr(in_value),1,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),7,4);
end;

// 39. Модуль с функциями Суммы Прописью(RUB) * Функция........... SummaPropis(X) * Программист....... Uncle Slava * Дата создания..... 16.11.98 * Принимает......... X - цифровое представление числа * Возвращает........ Строковое представление числа *  Аргументы:  Используются глобальные аргументы SummaScheta, Summa, SummaCop и Ostatok Назначение: Перевод числа (SummaScheta) в строковую константу Возвращает: SummaPropis - Сумму прописью  }
//Function SummaPropis(SummaScheta: Variant): ShortString;
//  var {Глобальные переменные} {SummaScheta:Variant;} Ostatok, Summa, OstatokCop: Variant; R, R1 : Variant; Gruppa, Dlina : Variant; Propis, PropisCop, S: String; i : Integer;
  {Единицы}   //  Function Edinici(R: Variant; Rod: String): String; begin case R of 1: if Rod = 'Мужской' then Edinici := 'один' else Edinici := 'одна'; 2: if Rod = 'Мужской' then Edinici := 'два' else Edinici := 'две'; 3: Edinici := 'три'; 4: Edinici := 'четыре'; 5: Edinici := 'пять'; 6: Edinici := 'шесть'; 7: Edinici := 'семь'; 8: Edinici := 'восемь'; 9: Edinici := 'девять'; 10: Edinici := 'десять'; 11: Edinici := 'одиннадцать'; 12: Edinici := 'двенадцать'; 13: Edinici := 'тринадцать'; 14: Edinici := 'четырнадцать'; 15: Edinici := 'пятнадцать'; 16: Edinici := 'шестнадцать'; 17: Edinici := 'семнадцать'; 18: Edinici := 'восемнадцать'; 19: Edinici := 'девятнадцать'; end; end;
  {Десятки}   //  Function Desatki(R: Variant): String; begin case R of 2: Desatki := 'двадцать'; 3: Desatki := 'тридцать'; 4: Desatki := 'сорок'; 5: Desatki := 'пятьдесят'; 6: Desatki := 'шестьдесят'; 7: Desatki := 'семьдесят'; 8: Desatki := 'восемьдесят'; 9: Desatki := 'девяносто'; end; end;
  {Сотни}     //  Function Sotni(R: Variant): String; begin case R of 1: Sotni := 'сто'; 2: Sotni := 'двести'; 3: Sotni := 'триста'; 4: Sotni := 'четыреста'; 5: Sotni := 'пятьсот'; 6: Sotni := 'шестьсот'; 7: Sotni := 'семьсот'; 8: Sotni := 'восемьсот'; 9: Sotni := 'девятьсот'; end; end;
  {Тысячи}    //  Function Tusachi(R: Variant): String; begin If R = 1 Then Tusachi := 'тысяча' else if (R > 1) And (R < 5) then Tusachi := 'тысячи' else Tusachi := 'тысяч'; end;
  {Миллионы}  //  Function Millioni(R: Variant): String; begin If R = 1 Then Millioni := 'миллион' else if (R > 1) And (R < 5) then Millioni := 'миллиона' else Millioni := 'миллионов'; end;
  {Миллиарды} // Function Milliardi(R: Variant): String; begin If R = 1 Then Milliardi := 'миллиард' else if (R > 1) And (R < 5) then Milliardi := 'миллиарда' else Milliardi := 'миллиардов'; end;
  {Копейки}   // Function Copeiki(R: Variant): String; begin If R = 1 Then Copeiki := '' else if (R > 1) And (R < 5) then Copeiki := '' else Copeiki := '' end;
  {Рубли}     // Function Rubli(R: Variant): String; begin If R = 1 Then Rubli := '' else if (R > 1) And (R < 5) then Rubli := '' else Rubli := '' end;
  { * Использую математические функции : * Abs(x)   - модуль числа.  Int(x)   - отделяет целую часть вещественного числа. * Frac(x)  - отделяет дробную часть вещественного числа. * Round(x) - округляет до целого числа. }
//begin
//  if Round(StrToFloat(SummaScheta))=0 then begin SummaPropis := 'Ноль'; Exit; end; Propis:=''; PropisCop:=''; S:=''; SummaScheta := Abs(SummaScheta); Ostatok := Int(SummaScheta); OstatokCop := Frac(SummaScheta); OstatokCop := Int(OstatokCop*100); Gruppa := Ostatok / 1000000000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000000000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10); Propis  := Propis + Sotni(R); Ostatok := Ostatok - R * 100 * 1000000000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000000000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, 'Мужской') + ' ' + Milliardi(R); Ostatok := Ostatok - R * 1000000000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000000000; Propis  := Propis + ' ' + Milliardi(R); end; end;
//  Gruppa := Ostatok / 1000000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10); if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100 * 1000000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, 'Мужской') + ' ' + Millioni(R); Ostatok := Ostatok - R * 1000000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000000; Propis  := Propis + ' ' + Millioni(R); end; end; Gruppa := Ostatok / 1000; if Gruppa >= 1 then begin R := Int(Gruppa / 100); if Ostatok = 1000 then R1 := Int(Gruppa / 10) else R1 := Int(Gruppa * 10);
//  if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100 * 1000; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10 * 1000; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, 'Женский') + ' ' + Tusachi(R); Ostatok := Ostatok - R * 1000; end else begin R := Int(Gruppa); Ostatok := Ostatok - R * 1000; Propis  := Propis + ' ' + Tusachi(R); end; end; Gruppa := Ostatok;
//  if Gruppa <> 0 then begin R := Int(Gruppa / 100); if Gruppa >= 100 then Propis  := Propis + ' ' + Sotni(R); Ostatok := Ostatok - R * 100; Gruppa  := Gruppa - R * 100; if Gruppa > 19 then begin R := Int(Gruppa / 10); Propis  := Propis + ' ' + Desatki(R); Ostatok := Ostatok - R * 10; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 0 then begin R := Int(Gruppa); Propis  := Propis + ' ' + Edinici(R, 'Мужской'); Ostatok := Ostatok - R; end else begin R := Int(Gruppa); Ostatok := Ostatok - R; end; end else If False then begin Gruppa := OstatokCop; if Gruppa > 19 then begin R := Int(Gruppa / 10); PropisCop := PropisCop + ' ' + Desatki(R); OstatokCop := OstatokCop - R * 10; Gruppa  := Gruppa - R * 10; end; if Int(Gruppa) > 2 then begin R := Int(Gruppa); PropisCop := PropisCop + ' ' + Edinici(R, 'Мужской') + ' ' + Copeiki(R); OstatokCop := OstatokCop - R; end else begin R := Int(Gruppa); OstatokCop := OstatokCop - R; PropisCop  := PropisCop + ' ' + Copeiki(R); end; end;
//  Dlina := Length(Propis); if VarIsNull(Dlina) then Exit; Propis:= Trim(Propis); S:=AnsiUpPerCase(COPY(Propis,1,1))+COPY(Propis,2,Length(Propis)-1); SummaPropis := S + PropisCop;
//end;

// 39. Сумма прописью (Модифицирован )
Function SummaPropis(In_Sum:Double): WideString;

  { Функция Conv999}
  function Conv999(M: longint; fm: integer): string;
    const c1to9m: array [1..9] of string [6]=('один','два','три','четыре','пять','шесть','семь','восемь','девять');
        c1to9f: array [1..9] of string [6]=('одна','две','три','четыре','пять','шесть','семь','восемь','девять');
        c11to19: array [1..9] of string [12]=('одиннадцать','двенадцать','тринадцать','четырнадцать','пятнадцать','шестнадцать','семнадцать','восемнадцать','девятнадцать');
        c10to90: array [1..9] of string [11]=('десять','двадцать','тридцать','сорок','пятьдесят','шестьдесят','семьдесят','восемьдесят','девяносто');
        c100to900: array [1..9] of string [9] =('сто','двести','триста','четыреста','пятьсот','шестьсот','семьсот','восемьсот','девятьсот');
  var s: string; i: longint;
  begin
    s := ''; i := M div 100; if i<>0 then s:=c100to900[i]+' '; M := M mod 100; i := M div 10;
    if (M>10) and (M<20) then s:=s+c11to19[M-10]+' ' else begin if i<>0 then s:=s+c10to90[i]+' '; M := M mod 10; if M<>0 then if fm=0 then s:=s+c1to9f[M]+' ' else s:=s+c1to9m[M]+' '; end;
    Conv999 := s;
  end;
var i: longint; j: longint; r: real; t: string; //S:Double;
begin
  { Преобразуем строку в тип Double }
  //S:=In_Sum;
  { Выполняем дальнейшие действия }
  t := ''; j := Trunc(In_Sum/1000000000.0); r := j; r := In_Sum - r*1000000000.0; i := Trunc(r);
  if j<>0 then begin t:=t+Conv999(j,1)+'миллиард'; j := j mod 100; if (j>10) and (j<20) then t:=t+'ов ' else case j mod 10 of 0: t:=t+'ов '; 1: t:=t+' '; 2..4: t:=t+'а '; 5..9: t:=t+'ов '; end; end;
  j := i div 1000000;
  if j<>0 then begin t:=t+Conv999(j,1)+'миллион'; j := j mod 100; if (j>10) and (j<20) then t:=t+'ов ' else case j mod 10 of 0: t:=t+'ов '; 1: t:=t+' '; 2..4: t:=t+'а '; 5..9: t:=t+'ов '; end; end;
  i := i mod 1000000; j := i div 1000;
  if j<>0 then begin t:=t+Conv999(j,0)+'тысяч'; j := j mod 100; if (j>10) and (j<20) then t:=t+' ' else case j mod 10 of 0: t:=t+' '; 1: t:=t+'а '; 2..4: t:=t+'и '; 5..9: t:=t+' '; end;
end;
  i := i mod 1000; j := i; if j<>0 then t:=t+Conv999(j,1);
  t := t {+'руб. '};  // не выводим руб.
  i := Round(Frac(In_Sum)*100.0);
  t := t {+IntToStr(i)+' коп.'}; // не выводим коп.
  SummaPropis:=AnsiUpperCase(COPY(t,1,1))+COPY(t,2,(Length(t)-1));
end;

// 39+. Сумма прописью (Модифицирован )
Function SummaPropis2(In_Sum:Double): WideString;
  { Функция Conv999}
  function Conv999(M: longint; fm: integer): string;
    const c1to9m: array [1..9] of string [6]=('один','два','три','четыре','пять','шесть','семь','восемь','девять');
        c1to9f: array [1..9] of string [6]=('одна','две','три','четыре','пять','шесть','семь','восемь','девять');
        c11to19: array [1..9] of string [12]=('одиннадцать','двенадцать','тринадцать','четырнадцать','пятнадцать','шестнадцать','семнадцать','восемнадцать','девятнадцать');
        c10to90: array [1..9] of string [11]=('десять','двадцать','тридцать','сорок','пятьдесят','шестьдесят','семьдесят','восемьдесят','девяносто');
        c100to900: array [1..9] of string [9] =('сто','двести','триста','четыреста','пятьсот','шестьсот','семьсот','восемьсот','девятьсот');
  var s: string; i: longint;
  begin
    s := ''; i := M div 100; if i<>0 then s:=c100to900[i]+' '; M := M mod 100; i := M div 10;
    if (M>10) and (M<20) then s:=s+c11to19[M-10]+' ' else begin if i<>0 then s:=s+c10to90[i]+' '; M := M mod 10; if M<>0 then if fm=0 then s:=s+c1to9f[M]+' ' else s:=s+c1to9m[M]+' '; end;
    Conv999 := s;
  end;
var i: longint; j: longint; r: real; t: string; //S:Double;
begin
  { Преобразуем строку в тип Double }
  //S:=In_Sum;
  { Выполняем дальнейшие действия }
  t := ''; j := Trunc(In_Sum/1000000000.0); r := j; r := In_Sum - r*1000000000.0; i := Trunc(r);
  if j<>0 then begin t:=t+Conv999(j,1)+'миллиард'; j := j mod 100; if (j>10) and (j<20) then t:=t+'ов ' else case j mod 10 of 0: t:=t+'ов '; 1: t:=t+' '; 2..4: t:=t+'а '; 5..9: t:=t+'ов '; end; end;
  j := i div 1000000;
  if j<>0 then begin t:=t+Conv999(j,1)+'миллион'; j := j mod 100; if (j>10) and (j<20) then t:=t+'ов ' else case j mod 10 of 0: t:=t+'ов '; 1: t:=t+' '; 2..4: t:=t+'а '; 5..9: t:=t+'ов '; end; end;
  i := i mod 1000000; j := i div 1000;
  if j<>0 then begin t:=t+Conv999(j,0)+'тысяч'; j := j mod 100; if (j>10) and (j<20) then t:=t+' ' else case j mod 10 of 0: t:=t+' '; 1: t:=t+'а '; 2..4: t:=t+'и '; 5..9: t:=t+' '; end;
end;
  i := i mod 1000; j := i; if j<>0 then t:=t+Conv999(j,1);
  t := t +'руб. ';
  i := Round(Frac(In_Sum)*100.0);
  //t := t + IntToStr(i) +' коп.';
  t := t + beforZero(i,2) +' коп.';
  SummaPropis2:=AnsiUpperCase(COPY(t,1,1))+COPY(t,2,(Length(t)-1));
end;

// 40. Функция преобразует дату 01.02.2002 в строку '2002-02-01'
Function StrDateFormat3(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat3:=COPY(DateToStr(in_value),7,2)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),1,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat3:=COPY(DateToStr(in_value),7,4)+'-'+COPY(DateToStr(in_value),4,2)+'-'+COPY(DateToStr(in_value),1,2);
end;

// 41. Функция передает Год из даты
Function YearFromDate(In_Date:TDate):Word;
var   YearVar, MonthVar, DayVar: Word;
begin
  DecodeDate(In_Date, YearVar, MonthVar, DayVar);
  YearFromDate:=YearVar;
end;

// 42. Функция из исходной строки In_String получает Хэш-функцию MD5
Function GenHashMD5(In_String:ShortString):ShortString;
begin
  GenHashMD5:=MD5DigestToStr(MD5String(In_String));
end;

// 43. Копирование файла
function WindowsCopyFile(FromFile, ToDir : string) : boolean;
var F : TShFileOpStruct;
begin
  F.Wnd := 0; F.wFunc := FO_COPY;
  FromFile:=FromFile+#0; F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0; F.pTo:=pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  result:=ShFileOperation(F) = 0;
end;

{ 44. Определение в системе переменной "Temp" как C:\Temp\ }
{ D7
function GetTempPathSystem: ShortString;
var Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer)-1,Buffer));
end; }

{ 45. Определение текущего каталога как C:\WORK }
{ D7
function GetCurrDir: ShortString;
var Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetCurrentDirectory(Sizeof(Buffer)-1, Buffer));
end; }

{ 46. Определение короткого имени файла "D:\WORK\read.txt" -> "read.txt" }
function getShortFileName(In_FileName:ShortString):ShortString;
begin
  Result:=ExtractFileName(In_FileName);
end;

{ 47. Определение пути по имени файла "D:\WORK\read.txt" -> "D:\WORK\" }
function getFilePath(In_FileName:ShortString):ShortString;
begin
  Result:=ExtractFilePath(In_FileName);
end;

{ 48. Определение короткого имени файла без расширения "D:\WORK\read.txt" -> "read" }
function getShortFileNameWithoutExt(In_FileName:ShortString):ShortString;
begin
  Result:=COPY(ExtractFileName(In_FileName),1,POS('.',ExtractFileName(In_FileName))-1);
end;

{ 49. Функция преобразует дату 01.02.2002 в строку '01022002' ДДММГГГГ }
Function StrDateFormat4(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat4:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat4:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,4);
end;

{ 50. Функция преобразует дату 01.02.2002 в строку '010202' ДДММГГ }
Function StrDateFormat5(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat5:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat5:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),9,2);
end;

{ 51. Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГГГЧЧММСС }
Function StrDateFormat6(in_value : TDateTime) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,4) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
end;

{ 52. Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГЧЧММСС }
Function StrDateFormat7(in_value : TDateTime) : shortString;
var tmp_StrDateFormat7: shortString;
begin
  IF Length(DateToStr(in_value))=8 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),9,2);
  { Время - если до 10:00:00 }
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
  { Результат }
  StrDateFormat7:=tmp_StrDateFormat7;
end;

{ 53. Функция находит в строке значение мужду двумя символами }
Function VariableBetweenChars(In_String: shortString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindChar(In_String, In_Char, In_CharNumberStart)+1, FindChar(In_String, In_Char, In_CharNumberEnd)-FindChar(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenChars:=VariableBetweenChars_tmp;
end;

{ 54. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString:=VariableBetweenChars_tmp;
end;

{ 54+. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString2(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString2:=VariableBetweenChars_tmp;
end;

{ 54++. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString3(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString2(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString2(In_String, In_Char, In_CharNumberEnd)-FindCharWideString2(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString3:=VariableBetweenChars_tmp;
end;

{ 55. Функция преобразует строку в формате даты и времени Инфоточки ITD '04-04-07 15:22:11' в тип TDateTime }
Function StrFormatDateTimeITDToDateTime(In_StrFormatDateTimeITD:ShortString):TDateTime;
begin
  StrFormatDateTimeITDToDateTime:=StrToDateTime(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2)+COPY(In_StrFormatDateTimeITD,9,9));
end;

{ 56. Функция преобразует строку в формате даты и времени Инфоточки ITD '04-04-07 15:22:11' в тип TDate }
Function StrFormatDateTimeITDToDate(In_StrFormatDateTimeITD:ShortString):TDate;
begin
  StrFormatDateTimeITDToDate:=StrToDate(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2));
end;

{ 57. Функция преобразует тип TDateTime в строковый формат даты и времени ITD }
Function DateTimeToStrFormatITDDateTime(In_DateTime:TDateTime):ShortString;
begin
  DateTimeToStrFormatITDDateTime:=COPY(DateTimeToStr(In_DateTime),1,2)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),9,11);
end;

{ 58. Функция для передаваемой строки In_StringForSign формирует ЭЦП RSA/MD5 с длиной ключа 1024 бит в кодировке hex. В In_fileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }
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

     { Проверяем наличие файла, содержащего RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Файл '+In_fileRSAPrivateKey+' не найден!');

           { Пример содержимого файла "RSA PRIVATE KEY"

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

     { Передается на вход строка, поэтому не проверяем наличие файла
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
             raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Ошибка чтения PRIVATE KEY из файла '+In_fileRSAPrivateKey+' !');
        end;

        //FileStream := TFileStream.Create(In_StringForSign, fmOpenRead);
        //nTamanho := FileStream.Size;

        oST := TStringStream.Create('');

        //oST.CopyFrom(FileStream,nTamanho);

        { Запись в oST данных из FileStream }
        oST.WriteString(In_StringForSign);

        { Размер строки }
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

        { Результат выводим в символах нижнего регистра - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 59. Функция для файла In_StringForSign формирует ЭЦП RSA/MD5 с длиной ключа 1024 бит в кодировке hex. В In_fileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }
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

     { Проверяем наличие файла, содержащего RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_File: Файл '+In_fileRSAPrivateKey+' не найден!');

           { Пример содержимого файла "RSA PRIVATE KEY"

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

     { Проверяем наличие файла }
     if FileExists(In_FileNameForSign) = false then
     begin
          raise Exception.Create('Sign_RSA_MD5_hex_File: Не найден файл '+In_FileNameForSign+'!');
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
             raise Exception.Create('Sign_RSA_MD5_hex_File: Ошибка чтения PRIVATE KEY из файла '+In_fileRSAPrivateKey+' !');
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

        { Результат выводим в символах нижнего регистра - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 60. Функция производит перемешку между собой случайным образом символов передаваемых в качестве параметра (перемешка mixing строки) }
Function mixingString(In_String:ShortString):ShortString;
var maxLengtIn_String:Word;
    s_tmp :ShortString;
    myHour, myMin, mySec, myMilli, mySecStamp : Word;
    i, posInS : Word;
begin

  { Временной срез }
  DecodeTime(Time, myHour, myMin, mySecStamp, myMilli);

  { Определяем длину в исходной строке }
  maxLengtIn_String:=Length(In_String);

  { Алгоритм работает для строки с нечетным количеством символов }
  IF (maxLengtIn_String MOD 2)=0
    THEN
      begin
        { Если длина четна, то добавляем 1 символ }
        In_String:=In_String+COPY(In_String,1,1);
      end; // If

  { Цикл }
  FOR i:=1 TO (mySecStamp+7) DO
    begin

      { Выполняем перемешку при каждом четном цикле }
      IF (i MOD 2)=0
        THEN
          begin
            In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);
          end // If
        ELSE
          begin
            { Выполняем перемешку при каждом нечетном цикле }
            In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);
          end;

      { Временной срез }
      DecodeTime(Time, myHour, myMin, mySec, myMilli);

      { Выполняем перемешку в зависимости от четности Миллисекунд }
      IF (myMilli MOD 2)=0
        THEN In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);

      { Выполняем перемешку в зависимости от четности Секунд }
      IF (mySec mod 2)=0
        THEN In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);

      { Выполняем перемешку в зависимости от четности Минут }
      IF (myMin mod 2)=0
        THEN In_String:=COPY(In_String,1,(Length(In_String) DIV 2)-1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1), (Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2), Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1))-(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)+1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1),1,(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)-1);

      { Делаем перестановку между 1-ым и 2-ым символом и так до конца посмледовательности }
      s_tmp:=''; posInS:=1;
      WHILE (posInS<Length(In_String)) DO
        begin
          //Application.ProcessMessages;
          { Новые миллисекунды }
          DecodeTime(Time, myHour, myMin, mySec, myMilli);
          IF (Random(myMilli) MOD 2)=0 THEN s_tmp:=s_tmp+In_String[posInS]+In_String[posInS+1] ELSE s_tmp:=s_tmp+In_String[posInS+1]+In_String[posInS];
          posInS:=posInS+2;
        end;
      IF posInS>=Length(In_String) THEN s_tmp:=s_tmp+In_String[posInS];
      { Результат }
      In_String:=s_tmp;
      //Application.ProcessMessages;
    end; // For

  { Приводим длину к исходной }
  IF maxLengtIn_String<>Length(In_String) THEN In_String:=COPY(In_String,2,Length(In_String)-1);

  Result:=In_String;
end;

{ 61. Функция выполняет StrToFloat с проверкой в In_String разделителя, соответствующего системно-установленному }
Function StrToFloat2(In_String:ShortString):Extended;
var pcLCA: array [0..20] of Char;
begin

  { Определяем системную переменную LOCALE_SDECIMAL }
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, pcLCA, 19);

  { Если в In_String разделитель "." а в системе "," }
  IF (POS('.', In_String)<>0)AND(POS(',', In_String)=0)AND(pcLCA[0]=',')
    THEN  In_String:=StringReplace(In_String, '.', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  { Если в In_String разделитель "," а в системе "." }
  IF (POS(',', In_String)<>0)AND(POS('.', In_String)=0)AND(pcLCA[0]='.')
    THEN  In_String:=StringReplace(In_String, ',', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  Result:=StrToFloat(In_String);

end;

{ 62. Функция получает сумму в строковом виде и преобразует разделитель к точке, запятой и копейки
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

  { Определяем знак }
  IF COPY(In_SumStr,1,1)='-'
    THEN
      begin
        minus:=True;
        In_SumStr:=COPY(In_SumStr, 2, Length(In_SumStr)-1);
      end
    ELSE minus:=False;

  { Определяем - есть ли разделитель. Он может быть: "." "," "=" }
  tmp_Sum:='';

  FOR i:=1 TO Length(In_SumStr) DO
    begin

      IF ((In_SumStr[i]<>' ')AND((In_SumStr[i]='0')OR(In_SumStr[i]='1')OR(In_SumStr[i]='2')OR(In_SumStr[i]='3')OR(In_SumStr[i]='4')OR(In_SumStr[i]='5')OR(In_SumStr[i]='6')OR(In_SumStr[i]='7')OR(In_SumStr[i]='8')OR(In_SumStr[i]='9')))
        THEN tmp_Sum:=tmp_Sum+In_SumStr[i];

      // Замена разделителя дробной части
      IF (In_SumStr[i]='-')or(In_SumStr[i]='.')or(In_SumStr[i]=',')or(In_SumStr[i]='=') THEN tmp_Sum:=tmp_Sum+In_Separator;

    end; // For

  { Разделитель }
  IF (POS(In_Separator, tmp_Sum)=0)AND(In_Decimal<>0)
    THEN tmp_Sum:=tmp_Sum+In_Separator;

  { Если In_Decimal=0, то удаляем справа за разделителем все символы 0 }
  IF (In_Decimal=0)
    THEN
      begin
        IF (POS('1',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('2',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('3',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('4',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('5',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('6',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('7',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('8',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('9',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)
          THEN tmp_Sum:=COPY(tmp_Sum, 1, POS(In_Separator, tmp_Sum)-1 );
      end; // If

  { Если есть разделитель, то считаем число знаков после него и если это число меньше чем In_Decimal - добавляем нулями }
  IF (POS(In_Separator, tmp_Sum)<>0)AND( ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) <In_Decimal)
    THEN
      begin
        FOR i:=1 TO ( In_Decimal - ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) ) DO
          begin
            tmp_Sum:=tmp_Sum+'0';
          end;
      end; // If

  { Подставляем знак }
  IF minus=True THEN Result:='-'+tmp_Sum ELSE Result:=tmp_Sum;

end;




{ Функция преобразует тип TDateTime в строковый формат даты и времени для сервера "Сирены" 2009-06-09T01:01:01.123456 }
Function DateTimeToStrFormatSirenaDateTime(In_DateTime:TDateTime):ShortString;
var  myHour, myMin, mySec, myMilli : Word;
begin
  { Временной срез }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );
  DateTimeToStrFormatSirenaDateTime:=COPY(DateTimeToStr(In_DateTime),7,4)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),1,2)
                                       +'T'
                                         { Время }
                                         +beforZero(myHour,2)+':'+beforZero(myMin,2)+':'+beforZero(mySec,2)
                                         {+COPY(DateTimeToStr(In_DateTime), POS(' ', DateTimeToStr(In_DateTime))+1, Length(DateTimeToStr(In_DateTime))-POS(' ', DateTimeToStr(In_DateTime)))}
                                           { миллисекунды через точку }
                                           +'.'+beforZero(myMilli,6);
end;

{ Функция преобразует дату 01.02.2002 в строку '020201' ГГММДД }
Function StrDateFormat8(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat8:=COPY(DateToStr(in_value),7,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat8:=COPY(DateToStr(in_value),9,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
end;

{ Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГЧЧММССMs }
Function StrDateFormat9(In_DateTime : TDateTime) : shortString;
var tmp_StrDateFormat9: shortString;
    myHour, myMin, mySec, myMilli : Word;
begin

  { Временной срез }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );

  IF Length(DateToStr(In_DateTime))=8 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),7,2);
  IF Length(DateToStr(In_DateTime))=10 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),9,2);
  { Время - если до 10:00:00 }
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
  { Результат }
  StrDateFormat9:=tmp_StrDateFormat9+IntToStr(myMilli);
end;

{  Функция преобразует дату и время 23.02.2009 12:37:00 в строку ГГГГММДДЧЧММСС }
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


{ Генерация UserName }
Function RandomUserName(PWLen: Word): ShortString;
var
  StrTableUserName: ShortString;
  N, K, X, Y: integer;// проверяем максимальную длину пароля
  Flags: TReplaceFlags;
begin

  { таблица символов, используемых в пароле }
  StrTableUserName:='1234567890';

  { Создаем уникальность таблицы символов, используя - mixingString }
  StrTableUserName:=DateTimeToStrFormat(Now)+StrTableUserName+DateTimeToStrFormat(Now);
  StrTableUserName:=mixingString(StrTableUserName);

  { Удаляем из этой уникальности: Нуль }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserName:=StringReplace(StrTableUserName, '0', '', Flags);

  if (PWlen > Length(StrTableUserName))
    then K := Length(StrTableUserName)-1
      else K := PWLen;
  SetLength(result, K); // устанавливаем длину конечной строки
  Y := Length(StrTableUserName); // Длина Таблицы для внутреннего цикла
  N := 0; // начальное значение цикла

  while N < K do
    begin// цикл для создания K символов
      X := Random(Y) + 1; // берём следующий случайный символ
      // проверяем присутствие этого символа в конечной строке
      if (pos(StrTableUserName[X], result) = 0)
        then
          begin
            inc(N); // символ не найден
            Result[N]:=StrTableUserName[X]; // теперь его сохраняем
          end; // If
    end; // While
end;

{ Генерация UserPassword }
Function RandomUserPassword(PWLen: Word): ShortString;
var
  N, K, X, Y: integer;// проверяем максимальную длину пароля
  StrTableUserPassword:ShortString;
  Flags: TReplaceFlags;
begin

  { таблица символов, используемых в пароле }
  // StrTableUserPassword:='1lwEkj532hefy89r4U38LEL384FV37847rfWFWKLlvhEERnsdfkiesu38KL543789JH332U84hfgHFgfdDY7Jhh8u4jc878weDfq534sxnewg4653sHyt28dh37dh36dh3kglgnbvhrf743jdjh437edhgafdh46sgd63g63GDJASG36d4GD5Wj5gf32HGXD';
  StrTableUserPassword:='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789';

  { Создаем уникальность таблицы символов, используя - mixingString }
  StrTableUserPassword:=DateTimeToStrFormat(Now)+StrTableUserPassword+DateTimeToStrFormat(Now);
  StrTableUserPassword:=mixingString(StrTableUserPassword);

  { Удаляем из этой уникальности: Нуль }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserPassword:=StringReplace(StrTableUserPassword, '0', '', Flags);

  { Удаляем из этой уникальности: "o" и "O" }
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'o', '', Flags);
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'O', '', Flags);

  if (PWlen > Length(StrTableUserPassword))
    then K := Length(StrTableUserPassword)-1
      else K := PWLen;
  SetLength(result, K); // устанавливаем длину конечной строки
  Y := Length(StrTableUserPassword); // Длина Таблицы для внутреннего цикла
  N := 0; // начальное значение цикла

  while N < K do
    begin// цикл для создания K символов
      X := Random(Y) + 1; // берём следующий случайный символ
      // проверяем присутствие этого символа в конечной строке
      if (pos(StrTableUserPassword[X], result) = 0)
        then
          begin
            inc(N); // символ не найден
            Result[N]:=StrTableUserPassword[X]; // теперь его сохраняем
          end; // If
    end; // While
end;

// Функция преобразует американский расчет дня недели в российский
Function RussianDayOfWeek(In_DayOfWeek:Byte):Byte;
begin
  IF in_DayOfWeek = 1
    THEN
      RussianDayOfWeek:=7
    ELSE
      RussianDayOfWeek:=in_DayOfWeek-1
end;

// Функция преобразует американский расчет дня недели в российский из даты
Function RussianDayOfWeekFromDate(In_Date:TDate):Byte;
var DayOfWeekVar:Byte;
begin

  DayOfWeekVar:=DayOfWeek( In_Date );

  IF DayOfWeekVar = 1
    THEN Result:=7
      ELSE Result:=DayOfWeekVar-1
end;

{ Количество выходных дней (субб., вскр.) между 2-мя датами }
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

{ Получение параметра (ShortString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
Function paramFromString(In_StringAnswer:WideString; In_Param:ShortString):ShortString;
begin
  { Версия не адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ Получение параметра (WideString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
Function paramFromString2(In_StringAnswer:WideString; In_Param:ShortString):WideString;
begin
  { Версия не адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ Получение параметра (WideString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; "
   - Адаптирована к параметр_номер_1 и параметр_номер_11.
   - Адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
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

{ Сохранение значение параметра в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
Function setParamFromString(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):ShortString;
var beforeSubstring, afterSubstring:ShortString; //str1:ShortString;
begin
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  { Если параметр есть в строке }
  IF POS(In_Param, In_StringAnswer)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param, In_StringAnswer)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { Если параметра нет в строке, то дописываем его в конец }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ Сохранение значение параметра (WideString) в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " Версия, адаптированная к регистру! }
Function setParamFromString2(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):WideString;
var beforeSubstring, afterSubstring:WideString;
    In_StringAnswer_tmp:WideString;
    In_Param_tmp:ShortString;
begin

  { Версия, адаптированная к регистру! }
  In_Param_tmp:=AnsiLowerCase(In_Param);
  In_StringAnswer_tmp:=AnsiLowerCase(In_StringAnswer);

  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';

  { Если параметр есть в строке }
  IF POS(In_Param_tmp, In_StringAnswer_tmp)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param_tmp, In_StringAnswer_tmp)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { Если параметра нет в строке, то дописываем его в конец }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ Получение количества параметров в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
Function countParamFromString(In_StringAnswer:WideString):Word;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
begin
  { Число параметров равно числу знаков = }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  { Поиск в подстроке }
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

{ Получение наименование параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = параметр_номер_2 }
Function paramNameFromString(In_StringAnswer:WideString; In_ParamNumber:Word):ShortString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { Определим в posRAVNO позицию знака "=" для искомого параметра }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { Поиск в подстроке }
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

  { Определим в подстроке "начало-posRAVNO" }
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
        { Получили имя параметра в зеркальном отображении: 2_ртемарап ("параметр_2"). Выполняем обратное преобразование }
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

{ Получение значение параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = 200.00 }
Function paramValueFromString(In_StringAnswer:WideString; In_ParamNumber:Word):WideString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { Определим в posRAVNO позицию знака "=" для искомого параметра }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { Поиск в подстроке }
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
  { Определим в подстроке "(posRAVNO+1)-конец" }
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

{ Функция из двойного параметра 1234-9044951501 выделяет первый 1234 (при In_ParamNumber=1) или второй 9044951501 (при In_ParamNumber=2) параметр }
Function getParamFromDoublePayment(In_DoubleAutData:ShortString; In_ParamNumber:Byte):ShortString;
var  autData, autData1, autData2:ShortString;
begin

  { В autData удаляем пробелы }
  autData:=StringReplace(In_DoubleAutData, ' ', '', [rfReplaceAll]);

  { Разбиваем autData на autData1 и autData2 }
  IF (POS('-',autData)<>0)
    THEN
      begin
        { Номер телефона }
        autData2:=COPY(autData, POS('-',autData)+1, Length(autData)-POS('-',autData) );
        { Данные для авторизации в Элси ДДММГГNNNNN }
        autData1:=COPY(autData, 1, POS('-',autData)-1 );
      end
    ELSE
      begin
        { Номер телефона }
        autData2:='';
        { Данные для авторизации в Элси ДДММГГNNNNN }
        autData1:=autData;
      end; // If

  { Результат }
  IF In_ParamNumber=1 THEN Result:=autData1 ELSE Result:=autData2;

end;

{ Перед передачей разультата для PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) спецсимволы " ; = # необходимо замаскировать функцией ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - производит маскирование. In_Mask_DeMask=DeMask - производит де-маскирование }
Function ps_paymGate_maskSymbol(In_String:WideString; In_Mask_DeMask:ShortString ):WideString;
begin
  { Если задано маскирование }
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

  { Если задано Де-маскирование }
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
  { Результат }
  Result:=In_String;
end;

{ Функция определяет локальный Ip адрес }
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

{ Маскирование середины строки }
Function maskString(In_StringForMask:ShortString):ShortString;
var startPosMask, endPosMask, i:Word;
begin
  Result:='';
  { Позиция начала маскирования }
  startPosMask:= ((Length(In_StringForMask) Div 2) Div 2)+2;
  { Позиция окончания маскирования }
  endPosMask:= (Length(In_StringForMask) Div 2) + ((Length(In_StringForMask) Div 2) Div 2);
  FOR i:=1 TO Length(In_StringForMask) DO
    begin
      { Находимся в диапазоне маскирования? }
      IF (i>=startPosMask)AND(i<=endPosMask)
        THEN
          begin
            { Маскируем }
            Result:=Result+'X';
          end
        ELSE
          begin
            Result:=Result+In_StringForMask[i];
          end; // If
    end; // For
end;

    { *** Конец раздела описания процедур и функций DLL *** }

    exports

{ *** Начало перечня экспортируемых из Dll процедур и функций *** }

// 1. Функция RoundCurrency округляет передаваемое ей значение до указанного количества знаков после запятой
RoundCurrency Name 'RoundCurrency',

// 2. Функция DosToWin преобразует Dos кодировку входящей строки в символы кодировки Windows
DosToWin Name 'DosToWin',

// 3. Функция WinToDos преобразует Windows кодировку входящей строки в символы кодировки Dos
WinToDos Name 'WinToDos',

// 4. Преобразование разделителя целой и дробной части (, -> .), представленного в строковом виде
ChangeSeparator Name 'ChangeSeparator',

// 5. Преобразование разделителя целой и дробной части (. -> ,), представленного в строковом виде
ChangeSeparator2 Name 'ChangeSeparator2',

// 6. Фиксированная строка выравнивание влево
LeftFixString Name 'LeftFixString',

// 7. Фиксированная строка выравнивание вправо
RightFixString Name 'RightFixString',

// 8. Фиксированная строка выравнивание по центру
CentrFixString Name 'CentrFixString',

// 9. Преобразование суммы из prn-файла
prnSum Name 'prnSum',

// 10. Преобразование строки '25 000,25' в число 25000,25
TrSum Name 'TrSum',

// 11. Преобразование текстовой даты "ДД.ММ.ГГГГ" в банковский день типа Int
bnkDay Name 'bnkDay',

// 12. Функция преобразует дату 01.01.2002 в строку '01/01/2002'
DiaStrDate Name 'DiaStrDate',

// 13. Функция преобразует дату 01.01.2002 в строку '"01" января 2002 г.'
PropisStrDate Name 'PropisStrDate',

// 14. Функция определяет в передаваемой строке, позицию номера сепаратора ^
FindSeparator Name 'FindSeparator',

// 15. Функция определяет в передаваемой строке, позицию номера передаваемого символа
FindChar Name 'FindChar',

// 15+. Функция определяет в передаваемой строке, позицию номера передаваемого символа
FindCharWideString Name 'FindCharWideString',

FindCharWideString2 Name 'FindCharWideString2',

// 16. Функция определяет в передаваемой строке, позицию пробела
FindSpace Name 'FindSpace',

{ Подсчет числа вхождений символа In_Char в строку In_String }
countCharInString Name 'countCharInString',

// 17. Функция преобразует Win строку 'Abcd' -> 'ABCD'
Upper Name 'Upper',

// 18. Функция преобразует Win строку 'abcd' -> 'Abcd'
Proper Name 'Proper',

// 19. Функция преобразует Win строку 'ABCD' -> 'abcd'
Lower Name 'Lower',

// 20. Функция преобразует строку '1000,00' -> '1 000,00'
Divide1000 Name 'Divide1000',

// 21. Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
paramFromIniFile Name 'paramFromIniFile',

paramFromIniFileWithOutMessDlg Name 'paramFromIniFileWithOutMessDlg',

paramFromIniFileWithOutMessDlg2 Name 'paramFromIniFileWithOutMessDlg2',

paramFromIniFileWithFullPath Name 'paramFromIniFileWithFullPath',

paramFromIniFileWithFullPathWithOutMessDlg Name 'paramFromIniFileWithFullPathWithOutMessDlg',

// 22. Функция ищет ini файл и параметр в нем; Если все нормально - возвращается значение параметра, если нет - то заначение функциий 'INIFILE_NOT_FOUND' или 'PARAMETR_NOT_FOUND'
paramFoundFromIniFile Name 'paramFoundFromIniFile',

// 23. Функция добавляет перед числом нули 1 до нужного количества знаков-> '0001'
beforZero Name 'beforZero',

// 24. Автонумерация документа из 12-х знаков с ведением электронного жунала
ID12docFromJournal Name 'ID12docFromJournal',

// 25. Преобразование Строки '01-01-05 01:01:01'
dateTimeToSec Name 'dateTimeToSec',

// 26. Преобразование String в PChar
StrToPchar Name 'StrToPchar',

// 27. Процедура выводит в лог файл с именем InFileName строку InString с переводом каретки если InLn='Ln'
ToLogFileWithName Name 'ToLogFileWithName',

// 27+. Процедура выводит в лог файл с именем InFileName строку InString с переводом каретки если InLn='Ln'
ToLogFileWideStringWithName Name 'ToLogFileWideStringWithName',

// 27++.
ToLogFileWithFullName Name 'ToLogFileWithFullName',

ToLogFileWideStringWithFullName Name 'ToLogFileWideStringWithFullName',

// 28. Функция преобразует строку Кириллицы в Латиницу по таблице транслитерации с www.beonline.ru
TranslitBeeLine Name 'TranslitBeeLine',

// 29. Функция преобразует дату 01.01.2002 в строку '01/01/2002'
formatMSSqlDate Name 'formatMSSqlDate',

// 30. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в тип TDateTime ( корректировку часового пояса +0300 пока не учитываем )
StrFormatTimeStampToDateTime Name 'StrFormatTimeStampToDateTime',

// 31. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в строку '04.04.2007 15:22:11'  ( корректировку часового пояса +0300 пока не учитываем )
StrTimeStampToStrDateTime Name 'StrTimeStampToStrDateTime',

// 32. Функция DateTimeToStrFormat преобразует дату и время  01.01.2007 1:02:00 в строку '0101200710200'
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

{ D7 GetTempPathSystem Name 'GetTempPathSystem', }

{ D7 GetCurrDir Name 'GetCurrDir', }

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

{ Результат ShortString: Получение параметра из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
paramFromString Name 'paramFromString',

{ Получение количества параметров в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
countParamFromString Name 'countParamFromString',

{ Получение наименование параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = параметр_номер_2 }
paramNameFromString Name 'paramNameFromString',

{ Получение значение параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = 200.00 }
paramValueFromString Name 'paramValueFromString',

{ Результат WideString: Получение параметра из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
paramFromString2 Name 'paramFromString2',

{ Результат WideString, адаптирована к регистру! }
paramFromString3 Name 'paramFromString3',

{ Сохранение значение параметра в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
setParamFromString Name 'setParamFromString',

{ Широкая строка! Адаптирована к регистру }
setParamFromString2 Name 'setParamFromString2',

getParamFromDoublePayment Name 'getParamFromDoublePayment',

{ Перед передачей разультата для PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) спецсимволы " ; = # необходимо замаскировать функцией ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - производит маскирование. In_Mask_DeMask=DeMask - производит де-маскирование }
ps_paymGate_maskSymbol Name 'ps_paymGate_maskSymbol',

{ Функция определяет локальный Ip адрес }
GetLocalIP Name 'GetLocalIP',

{ Маскирование середины строки }
maskString Name 'maskString'

;

{ *** Конец перечня экспортируемых из Dll процедур и функций *** }

begin
{ *** Начало блока инициализации Dll *** }
{ Код, помещенный в блоке инициализации автоматически выполняется при загрузке Dll }



{ *** Конец блока инициализации библиотеки *** }
end.
