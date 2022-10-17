{ *********************************************************************
  *
  * Author: Yernar Shambayev
  * E-mail: yernar@rambler.ru
  * GitHub: https://github.com/yernarsha
  * Description: Togyzkumalak class
  *
  ******************************************************************** }
unit tog;

interface

uses System.Classes, System.SysUtils;

const
  NUM_KUMALAKS = 9;
  NUM_FIELDS = NUM_KUMALAKS * 2 + 5;
  DRAW_GAME = NUM_KUMALAKS * NUM_KUMALAKS;
  TOTAL_KUMALAKS = DRAW_GAME * 2;
  TUZD = -1;
  CRLF = #13#10;

type
  TTogyzBoard = class(TObject)
  private
    finished: Boolean;
    gameResult: Integer;
    fields: TArray<Integer>;
    moves: TStringList;
    procedure checkPosition;
  public
    constructor Create;
    destructor Destroy; override;
    procedure newGame;
    function getNotation: String;
    function makeMove(move: Integer): String;
    function makeRandomMove: String;
    function isGameFinished: Boolean;
    function getBoard: TArray<Integer>;
    function getBoardStr: String;
    function getResult: Integer;
  end;

implementation

constructor TTogyzBoard.Create;
begin
  inherited;
  newGame;
end;

destructor TTogyzBoard.Destroy;
begin
  moves.Free;
  inherited;
end;

procedure TTogyzBoard.newGame;
var
  i: Integer;
begin
  finished := False;
  gameResult := -2;

  if Assigned(moves) then
    moves.Clear
  else
    moves := TStringList.Create;

  SetLength(fields, NUM_FIELDS);
  for i := 0 to NUM_FIELDS - 1 do
  begin
    if i < 18 then
      fields[i] := NUM_KUMALAKS
    else
      fields[i] := 0;
  end;
end;

function TTogyzBoard.getNotation: String;
var
  notation: String;
  i: Integer;
begin
  notation := '';
  for i := 0 to moves.Count - 1 do
  begin
    if i mod 2 = 0 then
      notation := notation + IntToStr(i div 2 + 1) + '. ' + moves[i]
    else
      notation := notation + ' ' + moves[i] + CRLF;
  end;

  Result := notation;
end;

procedure TTogyzBoard.checkPosition;
var
  i, color, numWhite, numBlack: Integer;
begin
  color := fields[22];
  numWhite := 0;

  for i := 0 to 8 do
  begin
    if fields[i] > 0 then
      numWhite := numWhite + fields[i];
  end;
  numBlack := TOTAL_KUMALAKS - numWhite - fields[20] - fields[21];

  if ((color = 0) and (numWhite = 0)) then
    fields[21] := fields[21] + numBlack
  else if ((color = 1) and (numBlack = 0)) then
    fields[20] := fields[20] + numWhite;

  if fields[20] > DRAW_GAME then
  begin
    finished := true;
    gameResult := 1;
  end
  else if fields[21] > DRAW_GAME then
  begin
    finished := true;
    gameResult := -1;
  end
  else if ((fields[20] = DRAW_GAME) and (fields[21] = DRAW_GAME)) then
  begin
    finished := true;
    gameResult := 0;
  end;
end;

function TTogyzBoard.makeMove(move: Integer): String;
var
  i, sow, color, num: Integer;
  tuzdCaptured: Boolean;
  madeMove: String;
begin
  tuzdCaptured := False;
  color := fields[22];
  madeMove := IntToStr(move);

  move := move + (color * 9) - 1;
  num := fields[move];

  if ((num = 0) or (num = TUZD)) then
  begin
    WriteLn('Incorrect move!');
    Result := '';
    Exit;
  end;

  if (num = 1) then
  begin
    fields[move] := 0;
    sow := 1;
  end
  else
  begin
    fields[move] := 1;
    sow := num - 1;
  end;

  num := move;
  for i := 1 to sow do
  begin
    Inc(num);
    if (num > 17) then
      num := 0;

    if (fields[num] = TUZD) then
    begin
      if (num < 9) then
        fields[21] := fields[21] + 1
      else
        fields[20] := fields[20] + 1;
    end
    else
      fields[num] := fields[num] + 1;
  end;

  if (fields[num] mod 2 = 0) then
  begin
    if ((color = 0) and (num > 8)) then
    begin
      fields[20] := fields[20] + fields[num];
      fields[num] := 0;
    end
    else if ((color = 1) and (num < 9)) then
    begin
      fields[21] := fields[21] + fields[num];
      fields[num] := 0;
    end;
  end
  else if (fields[num] = 3) then
  begin
    if ((color = 0) and (fields[18] = 0) and (num > 8) and (num < 17) and
      (fields[19] <> num - 8)) then
    begin
      fields[18] := num - 8;
      fields[num] := TUZD;
      fields[20] := fields[20] + 3;
      tuzdCaptured := true;
    end
    else if ((color = 1) and (fields[19] = 0) and (num < 8) and
      (fields[18] <> num + 1)) then
    begin
      fields[19] := num + 1;
      fields[num] := TUZD;
      fields[21] := fields[21] + 3;
      tuzdCaptured := true;
    end;
  end;

  if (color = 0) then
    fields[22] := 1
  else
    fields[22] := 0;

  if (num < 9) then
    num := num + 1
  else
    num := num - 8;

  madeMove := madeMove + IntToStr(num);
  if tuzdCaptured then
    madeMove := madeMove + 'x';

  moves.Add(madeMove);
  checkPosition;
  Result := madeMove;
end;

function TTogyzBoard.makeRandomMove: String;
var
  madeMove: String;
  possible: array of Integer;
  i, len, move, color, randomIndex, randMove: Integer;
begin
  SetLength(possible, 0);
  color := fields[22];

  for i := 1 to 9 do
  begin
    move := i + (color * 9) - 1;
    if fields[move] > 0 then
    begin
      len := Length(possible);
      SetLength(possible, len + 1);
      possible[len] := i;
    end;
  end;

  len := Length(possible);
  if len = 0 then
  begin
    WriteLn('No possible moves!');
    Result := '';
    Exit;
  end;

  if len = 1 then
    randomIndex := 0
  else
    randomIndex := Random(len);

  randMove := possible[randomIndex];
  madeMove := makeMove(randMove);
  Result := madeMove;
end;

function TTogyzBoard.isGameFinished: Boolean;
begin
  Result := finished;
end;

function TTogyzBoard.getBoard: TArray<Integer>;
begin
  Result := fields;
end;

function TTogyzBoard.getBoardStr: String;
var
  s: String;
  i: Integer;
begin
  s := '';

  for i := 0 to NUM_FIELDS - 1 do
  begin
    if i = NUM_FIELDS - 1 then
      s := s + IntToStr(fields[i])
    else
      s := s + IntToStr(fields[i]) + ',';
  end;

  Result := s;
end;

function TTogyzBoard.getResult: Integer;
begin
  Result := gameResult;
end;

end.
