unit U_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ComCtrls, DBGrids, ExtCtrls, StdCtrls, Buttons, DBCtrls, LResources, LR_Class,
  LR_DBSet, ZConnection, ZDataset, process;

type

  { TW_Main }

  TW_Main = class(TForm)
    BtnAdicionarPeca: TButton;
    BtnExcluirPeca: TButton;
    BtnExcluirProduto: TSpeedButton;
    BtnGerarCodigoQR: TSpeedButton;
    BtnExcluirPeca1: TSpeedButton;
    BtnImprimirLista: TSpeedButton;
    BtnLerCodigoQR: TSpeedButton;
    Button1: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    ComboBoxValor: TComboBox;
    ComboBoxTipo: TComboBox;
    DSBarcode: TDataSource;
    DBGridBarcodes: TDBGrid;
    DBGridHistorico: TDBGrid;
    DSLista: TDataSource;
    DSPecas: TDataSource;
    DSHistorico: TDataSource;
    DBGridLista: TDBGrid;
    DSProdutos: TDataSource;
    DBGridProdutos: TDBGrid;
    DBGridEstoque: TDBGrid;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    EditCodigoLido: TEdit;
    frDBDataSet1: TfrDBDataSet;
    frReport1: TfrReport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    BtnNovoProduto: TSpeedButton;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    QueryHistoricodata: TStringField;
    QueryHistoricodescricao: TStringField;
    QueryHistoricoid: TLargeintField;
    QueryHistoricoid_prod: TLargeintField;
    QueryHistoricoserie: TStringField;
    QueryListaid_peca: TLargeintField;
    QueryListaid_prod: TLargeintField;
    QueryListaquantidade: TLargeintField;
    QueryPecasdescricao: TStringField;
    QueryPecasid: TLargeintField;
    QueryPecasqtd_estoque: TLargeintField;
    QueryPecastipo: TStringField;
    QueryPecasvalor: TStringField;
    BtnInserirPeca: TSpeedButton;
    QueryProdutosid: TLargeintField;
    QueryProdutosnome: TStringField;
    StringField1: TStringField;
    StringField2: TStringField;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ZConnection1: TZConnection;
    QueryProdutos: TZQuery;
    QueryPecas: TZQuery;
    QueryHistorico: TZQuery;
    QueryLista: TZQuery;
    QueryBarcode: TZQuery;
    procedure BtnAdicionarPecaClick(Sender: TObject);
    procedure BtnExcluirPeca1Click(Sender: TObject);
    procedure BtnExcluirPecaClick(Sender: TObject);
    procedure BtnExcluirProdutoClick(Sender: TObject);
    procedure BtnGerarCodigoQRClick(Sender: TObject);
    procedure BtnImprimirListaClick(Sender: TObject);
    procedure BtnInserirPecaClick(Sender: TObject);
    procedure BtnNovoProdutoClick(Sender: TObject);
    procedure BtnLerCodigoQRClick(Sender: TObject);
    procedure ComboBoxTipoChange(Sender: TObject);
    procedure DSBarcodeDataChange(Sender: TObject; Field: TField);
    procedure DSProdutosDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    procedure FiltraHistorico(codigo: string);
  public

  end;

var
  W_Main: TW_Main;

implementation
  uses u_gera_barcode;

{$R *.lfm}

{ TW_Main }

//==============================================================================
//   Form - On Create
//==============================================================================
procedure TW_Main.FormCreate(Sender: TObject);
begin
  ZConnection1.Database:= 'database\Database.sqlite3';
  ZConnection1.LibraryLocation:= 'database\sqlite3.dll';

  BtnNovoProduto.Caption:= ' Novo' + #13#10 + 'Produto';
  BtnExcluirProduto.Caption:= ' Excluir' + #13#10 + 'Produto';
  PageControl1.ActivePageIndex:= 0;
  DSProdutos.OnDataChange:= @DSProdutosDataChange;
end;

procedure TW_Main.Label6Click(Sender: TObject);
begin

end;


//------------------------------------------------------------------------------
//      ___   __        _      __  _  ___  _   _       __
//       |   |_   |    |_|    |_  |_   |  | | | | | | |_
//       |   |__  |__  | |    |__  _|  |  |_| |_\ |_| |__
//
//------------------------------------------------------------------------------


//==============================================================================
//   ESTOQUE - Btn Adicionar Peça - On Click
//==============================================================================
procedure TW_Main.BtnAdicionarPecaClick(Sender: TObject);
begin
  //cria peça na tabela de peças
  QueryPecas.SQL.Clear;
  QueryPecas.SQL.Text:=  'INSERT INTO Pecas(tipo,valor,descricao,qtd_estoque) ' +
                          'VALUES(:tipo,:valor,:desc,:qtd)';
  if(CheckBox1.Checked)then
    QueryPecas.ParamByName('tipo').AsString:= ComboBox1.Text + ' (SMD)'
  else
    QueryPecas.ParamByName('tipo').AsString:= ComboBox1.Text;
  QueryPecas.ParamByName('valor').AsString:= Edit1.Text;
  QueryPecas.ParamByName('desc').AsString:= Edit2.Text;
  QueryPecas.ParamByName('qtd').AsInteger:= StrToInt(Edit4.Text);
  QueryPecas.ExecSQL;
  ZConnection1.Connected:= True;
  QueryPecas.SQL.Clear;
  QueryPecas.SQL.Text:= 'SELECT * FROM Pecas';
  QueryPecas.Open;
end;

//==============================================================================
//   ESTOQUE - Btn Excluir Peça - On Click
//==============================================================================
procedure TW_Main.BtnExcluirPecaClick(Sender: TObject);
begin
  if(not(DBGridEstoque.EditorMode))and(QueryPecas.RecordCount>0)then
  begin
    QueryPecas.Delete;
    QueryPecas.ApplyUpdates;
  end;
end;




//------------------------------------------------------------------------------
//      ___   __        _       __   __   _   _      ___  _   _
//       |   |_   |    |_|     |__| |__| | | | \ | |  |  | | |_
//       |   |__  |__  | |     |    | \  |_| |_/ |_|  |  |_|  _|
//
//------------------------------------------------------------------------------


//==============================================================================
//   Page Control - On Page Change
//       Objetivo: verificar as peças diferentes registradas na tabela
//       "Lista" para listar no combobox de seleção de tipo de peça.
//==============================================================================
procedure TW_Main.PageControl1Change(Sender: TObject);
var
  temp_query: TZQuery;
begin
  if(PageControl1.ActivePageIndex = 1)then
  begin
    temp_query:= TZQuery.Create(self);
    temp_query.Connection:= ZConnection1;
    temp_query.SQL.Text:= 'SELECT DISTINCT tipo FROM Pecas';
    temp_query.Active:= True;
    temp_query.ExecSQL;

    ZConnection1.Connected:= True;
    temp_query.Open;
    temp_query.First;

    //desvincula método "OnChange"
    ComboBoxTipo.OnChange:= nil;

    //preenche combobox de tipos de peças
    ComboBoxTipo.Items.Clear;
    while not temp_query.EOF do
    begin
      ComboBoxTipo.Items.Add(temp_query.FieldByName('tipo').AsString);
      temp_query.Next;
    end;

    //vincula método "OnChange"
    ComboBoxTipo.OnChange:= @ComboBoxTipoChange;
    temp_query.Close;
    temp_query.Free;
  end
  else
  if(PageControl1.ActivePageIndex = 2)then //aba Historico
  begin
    QueryHistorico.SQL.Clear();
    QueryHistorico.SQL.Text:= 'SELECT * FROM Historico';
    QueryHistorico.Open;
  end;
end;

//==============================================================================
//   PRODUTOS - ComboBoxTipo - On Change
//==============================================================================
procedure TW_Main.ComboBoxTipoChange(Sender: TObject);
var
  temp_query: TZQuery;
begin
  if(ComboBoxTipo.Text <> '')then
  begin
    temp_query:= TZQuery.Create(self);
    temp_query.Connection:= ZConnection1;
    temp_query.SQL.Text:= 'SELECT DISTINCT valor FROM Pecas WHERE tipo=' +
                          QuotedStr(ComboBoxTipo.Text);
    temp_query.Active:= True;
    temp_query.ExecSQL;

    ZConnection1.Connected:= True;
    temp_query.Open;

    temp_query.First;
    ComboBoxValor.Items.Clear;
    while not temp_query.EOF do
    begin
      ComboBoxValor.Items.Add(temp_query.FieldByName('valor').AsString);
      temp_query.Next;
    end;
    temp_query.Close;
    temp_query.Free;
  end;
end;

//==============================================================================
//   Data Source Produtos - On Change
//==============================================================================
procedure TW_Main.DSProdutosDataChange(Sender: TObject; Field: TField);
var
  prod_id: string;
begin
  if(QueryProdutos.Active)then
  begin
    prod_id:= DSProdutos.DataSet.Fields[0].AsString;
    if(prod_id <> '')then
    begin
      ZConnection1.Connected:= True;
      QueryLista.SQL.Clear;
      QueryLista.SQL.Text:= 'SELECT * FROM Lista WHERE id_prod=' + QuotedStr(prod_id);
      QueryLista.Open;
    end;
  end;
end;

//==============================================================================
//   PRODUTOS - Btn Novo Produto - On Click
//==============================================================================
procedure TW_Main.BtnNovoProdutoClick(Sender: TObject);
var
  nome: string;
begin
  nome:= InputBox('Novo Produto','Nome','');
  if(nome <> '')then
  begin
    QueryProdutos.SQL.Clear;
    QueryProdutos.SQL.Text:= 'INSERT INTO Produtos(nome) ' +
                             'VALUES(:nome)';
    QueryProdutos.ParamByName('nome').AsString:= nome;
    QueryProdutos.ExecSQL;

    ZConnection1.Connected:= True;
    QueryProdutos.SQL.Clear;
    QueryProdutos.SQL.Text:= 'SELECT * FROM Produtos';
    QueryProdutos.Open;
  end;
end;

//==============================================================================
//   PRODUTOS - Btn Excluir Produto - On Click
//==============================================================================
procedure TW_Main.BtnExcluirProdutoClick(Sender: TObject);
var
  prod_id: string;
  temp_query: TZQuery;
begin
  if(not(DBGridProdutos.EditorMode))and(QueryProdutos.RecordCount>0)then
  begin
    if(MessageDlg('Ao excluir o produto selecionado, a lista de peças e historicos '+
                  'associados também serão removidos. Deseja continuar?',
                  mtWarning,[mbYes,mbNo],0)=mrYes)then
    begin
      //pega o id do produto selecionado para exclusão
      prod_id:= DSProdutos.DataSet.Fields[0].AsString;

      //exclui os registros relacionados ao id do produto nas tabelas de
      //lista de peças e historico
      temp_query:= TZQuery.Create(self);
      temp_query.Connection:= ZConnection1;
      temp_query.SQL.Text:= 'DELETE FROM Lista where id_prod = ' + QuotedStr(prod_id);
      temp_query.ExecSQL;

      temp_query.SQL.Clear;
      temp_query.SQL.Text:= 'DELETE FROM CodBarras where id_prod = ' + QuotedStr(prod_id);
      temp_query.ExecSQL;

      {
      temp_query.SQL.Clear;
      temp_query.SQL.Text:= 'DELETE FROM Historico where id_prod = ' + QuotedStr(prod_id);
      temp_query.ExecSQL;
      }
      temp_query.Close;
      temp_query.Free;

      //por fim, exclui o item selecionado na tabela de produtos
      QueryProdutos.Delete;
      QueryProdutos.ApplyUpdates;
    end;
  end;
end;

//==============================================================================
//   PRODUTOS - Btn Inserir Peça (na lista de peças do produto) - On Click
//==============================================================================
procedure TW_Main.BtnInserirPecaClick(Sender: TObject);
var
  prod_id,peca_tipo,peca_valor: string;
  qtd: integer;
begin
  if(ComboBoxTipo.Text = '')then
  begin
    ShowMessage('Selecione o tipo da peça');
    ComboBoxTipo.SetFocus;
    exit;
  end;

  if(ComboBoxValor.Items.Count > 0)and(ComboBoxValor.Text = '')then
  begin
    ShowMessage('Selecione o valor da peça');
    ComboBoxValor.SetFocus;
    exit;
  end;

  prod_id:= DSProdutos.DataSet.Fields[0].AsString;
  if(prod_id = '')then
  begin
    ShowMessage('Erro - nenhum produto selecionado');
    Exit;
  end;

  peca_tipo:= ComboBoxTipo.Text;
  peca_valor:= ComboBoxValor.Text;
  qtd:= StrToInt(Edit3.Text);

  QueryLista.SQL.Clear;
  QueryLista.SQL.Text:= 'INSERT INTO Lista(id_prod,id_peca,quantidade) ' +
                        'VALUES(' +
                        '(SELECT id FROM Produtos WHERE id=' + QuotedStr(prod_id) + '),' +
                        '(SELECT id FROM Pecas WHERE tipo=' + QuotedStr(peca_tipo) +
                        ' AND valor=' + QuotedStr(peca_valor) + '),' +
                        ':qtd)';

  QueryLista.ParamByName('qtd').AsInteger:= qtd;

  QueryLista.ExecSQL;
  ZConnection1.Connected:= True;
  QueryLista.SQL.Clear;
  QueryLista.SQL.Text:= 'SELECT * FROM Lista WHERE id_prod=' + QuotedStr(prod_id);
  QueryLista.Open;
end;

//==============================================================================
//   PRODUTOS - Btn Excluir Peça (da lista de peças do produto) - On Click
//==============================================================================
procedure TW_Main.BtnExcluirPeca1Click(Sender: TObject);
begin
  //exclui o item selecionado na tabela Lista
  if(not(DBGridLista.EditorMode))and(QueryLista.RecordCount>0)then
  begin
    QueryLista.Delete;
    QueryLista.ApplyUpdates;
  end;
end;

//==============================================================================
//   PRODUTOS - Btn Gerar Codigo QR - On Click
//==============================================================================
procedure TW_Main.BtnGerarCodigoQRClick(Sender: TObject);
begin
  W_GenerateBarCode.ShowModal;
end;

//==============================================================================
//   PRODUTOS - Btn Imprimir Lista - On Click
//==============================================================================
procedure TW_Main.BtnImprimirListaClick(Sender: TObject);
begin
  frReport1.LoadFromFile('reports\Lista.lrf');
  frReport1.PrepareReport;
  frReport1.ShowReport;
end;



//------------------------------------------------------------------------------
//      ___   __        _              _  ___  _   _     __  _
//       |   |_   |    |_|     |__| | |_   |  | | |_| | |   | |
//       |   |__  |__  | |     |  | |  _|  |  |_| | \ | |__ |_|
//
//------------------------------------------------------------------------------


//==============================================================================
//   HISTORICO - Data Source Codigos de Barras - On Click
//==============================================================================
procedure TW_Main.DSBarcodeDataChange(Sender: TObject; Field: TField);
var
  serie: string;
begin
  //filtra as entradas com o codigo de barras selecionado
  if(QueryHistorico.Active)then
  begin
    serie:= DSBarCode.DataSet.Fields[0].AsString;
    if(serie <> '')then
    begin
      QueryHistorico.SQL.Clear;
      QueryHistorico.SQL.Text:= 'SELECT * FROM Historico WHERE serie=' + QuotedStr(serie);
      QueryHistorico.Open;
    end;
  end;
end;

//==============================================================================
//   HISTORICO - Btn Ler Codigo QR - On Click
//==============================================================================
procedure TW_Main.BtnLerCodigoQRClick(Sender: TObject);
var
  QRCodeReader: TProcess;
  Arq: TextFile;
  line: string;
  QRCode: string;
begin
  QRCodeReader:= TProcess.Create(self);
  QRCodeReader.Executable:= 'QRCodeReader\QRCodeReader.exe';
  QRCodeReader.Options:= QRCodeReader.Options + [poWaitOnExit];
  QRCodeReader.Execute; //chama o programa e espera terminar

  //verifica se o leitor de código QR gerou um arquivo com o resultado
  if(FileExists('QRCodeReader\qrcode.txt'))then
  begin
    QRCode:= '';
    AssignFile(Arq,'QRCodeReader\qrcode.txt');
    try
      Reset(Arq);
      QRCode:= '';
      while not EOF(Arq) do
      begin
        if(QRCode <> '')then
          QRCode:= QRCode + #13#10;
        ReadLn(Arq,line);
        QRCode:= QRCode + line;
      end;
    finally
      CloseFile(Arq);
    end;

    if(QRCode <> '')and(QRCode <> 'null')then
    begin
      EditCodigoLido.Text:= QRCode;
      FiltraHistorico(QRCode);
    end;
  end
  else
    EditCodigoLido.Text:= '';
  QRCodeReader.Free;
end;

procedure TW_Main.FiltraHistorico(codigo: string);
var
  produto: string;
  id_prod: integer;
  serie: string;
  i: integer;
  temp_query: TZQuery;
begin
  if(Pos('Produto: ', codigo) = 0)or(Pos('Serie: ', codigo) = 0)then
  begin
    ShowMessage('Código de barras inválido ou incompleto');
    Exit;
  end;

  //extrai o nome do produto do codigo de barras
  i:= Pos('Produto: ', codigo) + length('Produto: ');
  produto:= '';
  while(i <= length(codigo))and(codigo[i] <> #13)do
  begin
    produto:= produto + codigo[i];
    inc(i);
  end;

  //extrai o numero de serie do codigo de barras
  i:= Pos('Serie: ', codigo) + length('Serie: ');
  serie:= '';
  while(i <= length(codigo))and(codigo[i] <> #13)do
  begin
    serie:= serie + codigo[i];
    inc(i);
  end;

  //descobre o id do produto pelo nome do produto
  temp_query:= TZQuery.Create(self);
  temp_query.Connection:= ZConnection1;
  temp_query.SQL.Text:= 'SELECT id FROM Produtos WHERE nome=' + QuotedStr(produto);
  temp_query.Open;
  if(temp_query.Fields[0].IsNull)then
    id_prod:= -1
  else
    id_prod:= temp_query.Fields[0].AsInteger;

  //verifica se o numero de serie está salvo no historico
  temp_query.SQL.Text:= 'SELECT COUNT(1) FROM Historico WHERE serie=' + QuotedStr(serie);
  temp_query.Open;
  if(temp_query.Fields[0].AsInteger > 0)then
  begin
    //Entrada no histórico encontrada.
    //Filtra o historico pra apresentar todas as entradas correspondentes
    QueryHistorico.SQL.Clear;
    QueryHistorico.SQL.Text:= 'SELECT * FROM Historico WHERE serie=' + QuotedStr(serie);
    QueryHistorico.Open;
  end
  else
  begin
    if(MessageDlg('Codigo de barras não registrado. Deseja registrar?',
                  mtConfirmation, [mbYes,mbNo],0) = mrYes)then
    begin
      if(id_prod = -1)then
      begin
        ShowMessage('Produto não registrado. Necessário registrar o produto "' +
                    produto + '" antes de registrar o código de barras');
      end
      else
      begin
        temp_query.Close;
        temp_query.SQL.Clear();
        temp_query.SQL.Text:= 'INSERT INTO Historico(id_prod,serie,data) ' +
                              'VALUES(:id_prod,:serie,:data)';
        temp_query.ParamByName('id_prod').AsInteger:= id_prod;
        temp_query.ParamByName('serie').AsString:= serie;
        temp_query.ParamByName('data').AsString:= DateToStr(Now());
        temp_query.ExecSQL;
        temp_query.Close;
      end;
    end;
  end;

  temp_query.Free;
  W_Main.ZConnection1.Connected:= True;
end;

end.

