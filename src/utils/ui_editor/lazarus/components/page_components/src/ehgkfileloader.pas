unit EhgkFileLoader;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, pd_parser, EhgkPageContainer;

type
  TEhgkParseErrorEvent = procedure(Sender: TObject; const Msg: string) of object;

  TEhgkFileLoader = class(TComponent)
  private
    FFileName: String;
    FPageContainer: TEhgkPageContainer;
    FLastError: String;
    FOnParsed: TNotifyEvent;
    FOnError: TEhgkParseErrorEvent;
    procedure SetFileName(const AValue: String);
    procedure SetPageContainer(AValue: TEhgkPageContainer);
  public
    constructor Create(AOwner: TComponent); override;
    function Load: Boolean;
  published
    property FileName: String read FFileName write SetFileName;
    property PageContainer: TEhgkPageContainer read FPageContainer write SetPageContainer;
    property LastError: String read FLastError;
    property OnParsed: TNotifyEvent read FOnParsed write FOnParsed;
    property OnError: TEhgkParseErrorEvent read FOnError write FOnError;
  end;

procedure Register;

implementation

{ TEhgkFileLoader }

constructor TEhgkFileLoader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TEhgkFileLoader.SetFileName(const AValue: String);
begin
  if FFileName = AValue then Exit;
  FFileName := AValue;
  FLastError := '';
end;

procedure TEhgkFileLoader.SetPageContainer(AValue: TEhgkPageContainer);
begin
  if FPageContainer = AValue then Exit;
  FPageContainer := AValue;
end;

function TEhgkFileLoader.Load: Boolean;
var
  TempPages: TPagesList;
  i: Integer;
begin
  Result := False;
  FLastError := '';

  if FFileName = '' then
  begin
    FLastError := 'FileName is not set';
    if Assigned(FOnError) then FOnError(Self, FLastError);
    Exit;
  end;

  if not FileExists(FFileName) then
  begin
    FLastError := Format('File not found: %s', [FFileName]);
    if Assigned(FOnError) then FOnError(Self, FLastError);
    Exit;
  end;

  if FPageContainer = nil then
  begin
    FLastError := 'PageContainer is not set';
    if Assigned(FOnError) then FOnError(Self, FLastError);
    Exit;
  end;

  TempPages := TPagesList.Create;
  try
    try
      Result := ParsePages(FFileName, TempPages);
      if not Result then
      begin
        FLastError := 'Parse failed';
        if Assigned(FOnError) then FOnError(Self, FLastError);
        Exit;
      end;

      // Container is always cleared before filling
      // TODO FPageContainer.Clear;

      for i := 0 to TempPages.Count - 1 do
        // TODO FPageContainer.AddPage(TempPages[i]);

      if Assigned(FOnParsed) then FOnParsed(Self);
    except
      on E: Exception do
      begin
        FLastError := E.Message;
        if Assigned(FOnError) then FOnError(Self, FLastError);
      end;
    end;
  finally
    TempPages.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('EHGK', [TEhgkFileLoader]);
end;

initialization
  {$I ehgksaveload.lrs}

end.
