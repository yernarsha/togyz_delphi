unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Layouts, FMX.ListBox, FMX.Controls, FMX.TMSBaseControl,
  FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid,
  FMX.TMSGrid, FMX.Types, FMX.Objects, FMX.Forms, FMX.Dialogs,
  FMX.TMSCustomButton, FMX.TMSSpeedButton;

type
  TTogyzForm = class(TForm)
    TogyzRectangle: TRectangle;
    BoardGrid: TTMSFMXGrid;
    MovesListBox: TListBox;
    NewGameSpeedButton: TTMSFMXSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BoardGridGetCellLayout(Sender: TObject; ACol, ARow: Integer;
      ALayout: TTMSFMXGridCellLayout; ACellState: TCellState);
    procedure BoardGridGetCellReadOnly(Sender: TObject; ACol, ARow: Integer;
      var AReadOnly: Boolean);
    procedure BoardGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var Allow: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewGameSpeedButtonClick(Sender: TObject);
  private
    procedure Common_Fill_Grid(Grid: TTMSFMXGrid);
    procedure Prepare_Grid(Grid: TTMSFMXGrid);
    procedure Fill_Grid(Grid: TTMSFMXGrid);
    procedure MakeDBMove(ACol, ARow: Integer);
    procedure AI_Move;
  public
  end;

var
  TogyzForm: TTogyzForm;

implementation

uses tog, FMX.Platform;

{$R *.fmx}

var
  tBoard: TTogyzBoard;

procedure TTogyzForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(tBoard) then
    tBoard.Free;
end;

procedure TTogyzForm.FormCreate(Sender: TObject);
begin
  TogyzRectangle.Fill.Color := $FFC1734F;
  tBoard := TTogyzBoard.Create;

  Prepare_Grid(BoardGrid);
  Common_Fill_Grid(BoardGrid);
  Fill_Grid(BoardGrid);
end;

procedure TTogyzForm.Prepare_Grid(Grid: TTMSFMXGrid);
const
  ColCount = NUM_KUMALAKS;
  RowCount = 5;
var
  I: Integer;
begin
  Grid.Options.ScrollBar.HorizontalScrollBarVisible := False;
  Grid.Options.ScrollBar.VerticalScrollBarVisible := False;
  Grid.Options.Mouse.TouchScrolling := True;

  Grid.ColumnCount := ColCount;
  Grid.RowCount := RowCount;
  Grid.FixedColumns := 0;
  Grid.FixedRows := 0;
  Grid.Fill.Color := $FF3F3F3F;

  // Grid.RowHeights[0] :=;
  Grid.RowHeights[1] := Grid.DefaultRowHeight * 3;
  Grid.RowHeights[2] := Grid.DefaultRowHeight * 2;
  Grid.RowHeights[3] := Grid.RowHeights[1];
  Grid.RowHeights[4] := Grid.RowHeights[0];
  Grid.Height := Grid.DefaultRowHeight * 10 + 3;

  for I := 0 to ColCount - 1 do
    Grid.ColumnWidths[I] := Grid.Width / ColCount;

  Grid.MergeCells(3, 2, 6, 1);
  Grid.MergeCells(0, 2, 3, 1);
end;

procedure TTogyzForm.Common_Fill_Grid(Grid: TTMSFMXGrid);
var
  I: Integer;
begin
  for I := 0 to NUM_KUMALAKS - 1 do
  begin
    Grid.Cells[I, 4] := IntToStr(I + 1);
    Grid.Cells[NUM_KUMALAKS - I - 1, 0] := IntToStr(I + 1);
  end;
end;

procedure TTogyzForm.Fill_Grid(Grid: TTMSFMXGrid);
var
  I, NumKum: Integer;
  CellStr: String;
  board: TArray<Integer>;
begin
  board := tBoard.getBoard;

  if (board[NUM_FIELDS - 1] = 0) then
    Grid.Cells[0, 2] := 'White turn'
  else
    Grid.Cells[0, 2] := 'Black turn';

  for I := 0 to NUM_KUMALAKS * 2 - 1 do
  begin
    NumKum := board[I];

    if (NumKum = -1) then
      CellStr := 'X'
    else if (NumKum = 0) then
      CellStr := ''
    else
      CellStr := IntToStr(NumKum);

    if (I < NUM_KUMALAKS) then
      Grid.Cells[I, 3] := CellStr
    else
      Grid.Cells[2 * NUM_KUMALAKS - I - 1, 1] := CellStr;
  end;

  Grid.Cells[0, 2] := Grid.Cells[0, 2] + '     ' + IntToStr(board[20]) + ' : ' +
    IntToStr(board[21]);
  Grid.Cells[3, 2] := tBoard.getBoardStr;
end;

procedure TTogyzForm.BoardGridGetCellLayout(Sender: TObject;
  ACol, ARow: Integer; ALayout: TTMSFMXGridCellLayout; ACellState: TCellState);
const
  OtauColor = $FF995435;
begin
  if (ARow = 1) or (ARow = 3) then
  begin
    if (ARow = 1) then
    begin
      ALayout.Fill.Color := OtauColor;
      ALayout.FontFill.Color := TAlphaColors.black;
    end
    else
    begin
      ALayout.Fill.Color := OtauColor;
      ALayout.FontFill.Color := TAlphaColors.white;
    end;

    ALayout.Font.Size := 20;
    ALayout.TextAlign := TTextAlign.Center;
  end

  else
  begin
    ALayout.Fill.Color := $FF3F3F3F;
    ALayout.FontFill.Color := TAlphaColors.white;

    if (ARow = 2) then
    begin
      ALayout.Font.Size := 16;
      ALayout.Font.Style := [TFontStyle.fsBold];
      ALayout.TextAlign := TTextAlign.Center;
    end

    else
    begin
      ALayout.Font.Size := 12;
      ALayout.TextAlign := TTextAlign.Center;
    end;
  end;
end;

procedure TTogyzForm.BoardGridGetCellReadOnly(Sender: TObject;
  ACol, ARow: Integer; var AReadOnly: Boolean);
begin
  AReadOnly := True;
end;

procedure TTogyzForm.BoardGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var Allow: Boolean);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc)
  then
    Svc.SetClipboard(tBoard.getBoardStr);

  if tBoard.isGameFinished then
    Exit;

  if (ARow = 1) or (ARow = 3) then
    MakeDBMove(ACol, ARow);
end;

procedure TTogyzForm.MakeDBMove(ACol, ARow: Integer);
var
  CurrPlayer, NumKum, NumOtau, MyMove: Integer;
  Svc: IFMXClipboardService;
  board: TArray<Integer>;
begin
  board := tBoard.getBoard;
  CurrPlayer := board[NUM_FIELDS - 1];

  if ((CurrPlayer = 0) and (ARow = 1)) or ((CurrPlayer = 1) and (ARow = 3)) then
    Exit;

  if (ARow = 1) then
  begin
    NumOtau := NUM_KUMALAKS * 2 - 1 - ACol;
    MyMove := NUM_KUMALAKS - ACol;
  end
  else
  begin
    NumOtau := ACol;
    MyMove := ACol + 1;
  end;

  NumKum := board[NumOtau];
  if (NumKum <= 0) then
    Exit;

  tBoard.makeMove(MyMove);

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc)
  then
    Svc.SetClipboard(tBoard.getBoardStr);

  Fill_Grid(BoardGrid);

  MovesListBox.BeginUpdate;
  try
    MovesListBox.Items.Text := tBoard.getNotation;
  finally
    MovesListBox.EndUpdate;
  end;

  if not tBoard.isGameFinished then
    AI_Move
  else
    ShowMessage('Game over!');
end;

procedure TTogyzForm.AI_Move;
begin
  tBoard.makeRandomMove;
  Fill_Grid(BoardGrid);

  MovesListBox.BeginUpdate;
  try
    MovesListBox.Items.Text := tBoard.getNotation;
  finally
    MovesListBox.EndUpdate;
  end;

  if tBoard.isGameFinished then
    ShowMessage('Game over!');
end;

procedure TTogyzForm.NewGameSpeedButtonClick(Sender: TObject);
begin
  tBoard.newGame;
  Fill_Grid(BoardGrid);
  MovesListBox.Clear;
end;

end.
