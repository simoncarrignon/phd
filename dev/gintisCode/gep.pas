unit GEp;

//  See C:\Papers\General Equilibrium\General Equilibrium.tex
//  Version with new calculation of EZ
interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    Math, StdCtrls,Histogram,XYGraphu,RAverageU,Sort,Menus,ExtCtrls,Report,
    ComCtrls, Spin;
const
    KStar : Integer = 35; //Optimal firm size
    FirmReplacementRate : Real = 0.10;
    WorkerReplacementRate : Real = 0.05;
    MinFirms = 4; //Minimum number of firms in a industry
    CheckPeriod : Integer = 25; // plot points, etc. every multiple of this
    CheckHistogramPeriod = 500;
    NTiles = 10;
    MaxProbes = 12;
    MinProbes = 6;
    DepreciationFactor : Real = 0.9;
    CapitalSupplyPerFirm = 10;
    PriceHistoryLength = 5;
var
    Vision : Integer; // running average length
    EZVision : Integer; // Averaging for EZ
    MinElSubst,MaxElSubst,MutationRate,FirmMutationRate,
    WorkerMutationRate,TotalIncome,AverageProfits,AverageWealth : Extended;
    CapitalSupply,EffortMin,EffortMax,
    WageMin,WageMax,EZMin,EZMax,
    SDMin,SDMax,NumFirmsMin,
    NumFirmsMax,EmployeeMin,EmployeeMax : Real;
    CalibratePeriod,AveProfDenom,AveWealthDenom : Integer;

type
    Good = class(TObject)
    Supply,Demand,AveWage,AveProfit,TEffort,AveEZ : Real;
    NumFirms,GIndex,TEmployed,OptimalEmployees,MaxEmployees : Integer;
    SupplyAve,PriceAve,CapitalAve,DemandAve,TargetEmploymentAve,
    CEffortAve,ProfitAve,NumFirmsAve,EmployeeAve,EffortAve,WageAve,
    EZAve: TRAverage;
    Constructor Init(I : Integer);
    Destructor Destroy; override;
    Procedure InitializeMicroGraph;
    Procedure InitializeMacroGraph;
    Procedure AddFirm(CopyExisting : Boolean);
    Procedure DropEmployer(I : Integer);
    Procedure DropFirm(I : Integer);
    Procedure DropAFirm;
    Function AddOneFirm : Boolean;
    Function DropOneFirm : Boolean;
    Procedure GetNextFirmGeneration;
    Procedure AdjustEmployees;
    Procedure AdjustEmployer;
    Procedure Employ(F,W : Integer;CLEffort : Real);
    Procedure DisplayHistogram;
    Function HireWorker(LWage,LCEffort : Real;NewEmployer : Integer) : Integer;
end;
TForm1 = class(TForm)
RunButton: TButton;
Label2: TLabel;
NumWorkersBox: TEdit;
Label3: TLabel;
TotalPeriodsBox: TEdit;
HaltButton: TButton;
QuitButton: TButton;
CurrentPeriod: TEdit;
Label4: TLabel;
Label7: TLabel;
NumFirmsBox: TEdit;
MaxDiscountRateBox: TEdit;
Label10: TLabel;
MinCostOfEffortBox: TEdit;
Label11: TLabel;
NumGoodsBox: TEdit;
Label5: TLabel;
UnemploymentWageBox: TEdit;
ShowFirmHistogramBox: TCheckBox;
Label17: TLabel;
VisionBox: TEdit;
Label18: TLabel;
FirmMutationRateBox: TEdit;
Label19: TLabel;
WorkerMutationRateBox: TEdit;
Label12: TLabel;
MinPriceBox: TEdit;
Label6: TLabel;
MaxPriceBox: TEdit;
Label15: TLabel;
MaxCostofEffortBox: TEdit;
Label16: TLabel;
Label8: TLabel;
Label13: TLabel;
MinElSubstBox: TEdit;
MaxElSubstBox: TEdit;
LoadGeParDlg: TOpenDialog;
LoadPlotBtn: TButton;
PlotNameBox: TEdit;
SavePlotBtn: TButton;
Label1: TLabel;
SaveGeParDlg: TSaveDialog;
CheckPeriodBox: TEdit;
Label14: TLabel;
Label20: TLabel;
DepreciationRateBox: TEdit;
Label9: TLabel;
MinDiscountRateBox: TEdit;
DebugBox: TCheckBox;
Label25: TLabel;
Label26: TLabel;
MinimumWageBox: TEdit;
MaximumWageBox: TEdit;
SectorBox: TSpinEdit;
ShowSectorBtn: TButton;
Label29: TLabel;
ShowSectorsBox: TSpinEdit;
ReportBox: TCheckBox;
Label21: TLabel;
CalibratePeriodBox: TEdit;
MainMenu1: TMainMenu;
File1: TMenuItem;
Load1: TMenuItem;
Save1: TMenuItem;
N1: TMenuItem;
Halt1: TMenuItem;
Exit1: TMenuItem;
Execute1: TMenuItem;
Run1: TMenuItem;
CheckDemand1: TMenuItem;
N2: TMenuItem;
CreateNewScript1: TMenuItem;
EditScript1: TMenuItem;
RunScript1: TMenuItem;
Label22: TLabel;
NumExecutionsBox: TEdit;
Label23: TLabel;
CurrExecutionBox: TEdit;
SpinEdit1: TSpinEdit;
Label24: TLabel;
LoadParamsBtn: TButton;
SaveParamsBtn: TButton;
LoadParameters1: TMenuItem;
SaveParameters1: TMenuItem;
LoadParamsDlg: TOpenDialog;
SaveParamsDlg: TSaveDialog;
ShockBox: TCheckBox;
Label30: TLabel;
STartShockBox: TEdit;
Label31: TLabel;
Label32: TLabel;
ShockDurationBox: TEdit;
Label27: TLabel;
EZVisionBox: TEdit;
ZeroFallbackBox: TCheckBox;
LaborShockCk: TCheckBox;
ExtremeInitializationCk: TCheckBox;
ShowAdjustGraphBox: TCheckBox;
ShowPriceGraphBox: TCheckBox;
ShowProfitsGraphBox: TCheckBox;
ShowWealthGraphBox: TCheckBox;
ShowCapitalPriceGraphBox: TCheckBox;
ShowEfficiencyGraphBox: TCheckBox;
procedure RunButtonClick(Sender: TObject);
procedure HaltButtonClick(Sender: TObject);
procedure FormClose(Sender: TObject; var Action: TCloseAction);
procedure QuitButtonClick(Sender: TObject);
procedure HaltButtonMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    Procedure DisplayResults;
    Procedure Calibrate;
procedure CheckDemandBtnClick(Sender: TObject);
procedure LoadPlotBtnClick(Sender: TObject);
procedure SavePlotBtnClick(Sender: TObject);
procedure ShowSectorBtnClick(Sender: TObject);
procedure SectorBoxChange(Sender: TObject);
procedure FormCreate(Sender: TObject);
procedure ReportBoxClick(Sender: TObject);
procedure Save1Click(Sender: TObject);
procedure Halt1Click(Sender: TObject);
procedure Exit1Click(Sender: TObject);
procedure Load1Click(Sender: TObject);
procedure Run1Click(Sender: TObject);
procedure CheckDemand1Click(Sender: TObject);
procedure CreateNewScript1Click(Sender: TObject);
procedure EditScript1Click(Sender: TObject);
procedure RunScript1Click(Sender: TObject);
procedure SpinEdit1Change(Sender: TObject);
procedure LoadParamsBtnClick(Sender: TObject);
procedure SaveParamsBtnClick(Sender: TObject);
procedure LoadParameters1Click(Sender: TObject);
procedure SaveParameters1Click(Sender: TObject);
  private
      Procedure InitializePriceGraph;
      Procedure InitializeEfficiencyGraph;
      Procedure InitializeAdjustGraph;
      Procedure InitializeCapitalPriceGraph;
      Procedure InitializeWealthGraph;
      Procedure LaborShock;
      Procedure CapitalShock;
      Procedure CheckShock;
      Procedure FirmsReproduce;
      Procedure AddAndDropFirms;
  public
      Running,HaltSimulation : Boolean;
      Procedure InitializeEmployment;
      Procedure InitializeAssetDistribution;
      Procedure GetWorkerStats;
      Procedure Mutate;
      Procedure GetFirmStats;
      Procedure NewFallbacks;
      Procedure PriceAdjust;
      Procedure Produce;
      Procedure Pay;
      Procedure Sell;
      Procedure CheckAssignments;
      Function InitializePriceAdjust : Real;
      Procedure InitializeProfitsGraph;
      Function InitializeFirmAdjust : Real;
      Procedure Delay(Num: Cardinal);
      Function PricesStdDev : Real;
      Procedure AllocateCapital;
  end;
type
    GoodsSegment = class(TObject)
    GSNumGoods,GSOwner,GSSegNumber : Integer;
    GSGoodIndex : Array of Integer;
    GSShare : Array of Real;
    GSGamma : Real;
    Constructor Init(GoodsInSeg,SegOwner,SegNumber : Integer); virtual;
    Destructor Free; virtual;
    Procedure GetOptimalDemandForSegment;
    Procedure GSGetDemand;
    Function GSUtility : Real;
end;
Worker = class(TObject)
EZ : Real;
DUEffort,Rho,Delta,Wealth,CurrentIncome,KAsset,
CUtility : Real;
PriceHistory : Array of Array of Real;
PriceHPointer : Integer;
WDemand : Array of Real;
ShareSeg : Array of Real;
WSupplier : Array of Integer;
WPrice : Array of Real;
NumProbes : Array of Integer;
NumSegments : Integer;
Segments : Array of GoodsSegment;
Employer,Industry : Integer;
Employed : Boolean;
WIndex : Integer;
Consumption : Array of TRAverage;
IncomeAve : TRAverage;
OptimalConsumption : Array of Real;
AverageWage : TRAverage;
Constructor Init(I : Integer); virtual;
Destructor Free; virtual;
Function DiddleValue(R : Real) : Real;
Procedure GetSuppliersAndPrices;
Procedure Shop;
Procedure GetDemand;
Procedure Quit;
Procedure SwitchEmployer(J,K : Integer);
Function ConsumptionUtility : Real;
Function OptimalUtility : Real;
Procedure SetOptimalConsumption;
Function InitialEZ : Real;
Function BeatsFallback(Offer : Real) : Boolean;
	end;
	Firm = class(TObject)
	Price,Wage,Profit,Inventory,CEffort,Capital,
	PriceAdjustCoefficient,PriceFloor,
	FirmAdjustCoefficient : Real;
	Product,TargetEmployment,NextWorker : Integer;
	WW : Array of Integer;
	Constructor Init(Copy : Boolean;G : Good);
	Destructor Destroy; override;
	Function ProductEffort(GI:Integer;Employees:Integer):Real;
	Procedure DismissWorker(I : Integer);
	Procedure LayoffWorker;
	Function DiddleValue(R : Real) : Real;
	Function EstimateEZ : Real;
	Function DemandForCapital(R : Real) : Real;
    end;
var
    AdjustGraph,CapitalPriceGraph,EfficiencyGraph,PriceGraph,WealthGraph,
    ProfitsGraph : TXYGraph;
    MicroGraph : Array of TXYGraph;
    MicroGraphLength : Integer;
    MacroGraph : Array of TXYGraph;
    MacroGraphLength : Integer;
    LoadGraph : Array of TXYGraph;
    LoadGraphLength : Integer;
    Workers : Array of Worker;
    AggOptConsumption : Array of Real;
    Firms : Array of Array of Firm;
    Goods : Array of Good;
    ShockPeriod,ShockDuration,ShockIteration,NumGoods,ShowGraphs,HGap : Integer;
    InShock,ExtremeInitialize : Boolean;
    PCaption : String;
    TotalEmployedAve,CapitalRentalPriceAve,PriceAdjustCoefficientAve,
    FirmAdjustCoefficientAve,FoundEmploymentAve,LostEmploymentAve,
    FirmEstEZAve,EfficiencyAve : TRAverage;
    Periods : Integer;
    AXMin,AXMax,DiddleAdjust,CapitalRentalPrice,MinPrice,MaxPrice,
    WorkerAdjustCoefficient,TaxRate : Real;
    TotalEmployed, // Computed in Pay
    FoundEmployment, // Computed in HireWorker
    LostEmployment, // Computed in DismissWorker and LayoffWorker
    NumWorkers,
    OldIntValue1,
    TotalNumFirms : Integer; // Computed in RunButtonClick
    TotalPeriods : Longint;
    Outfname : String;
    ParamfileName : String;
    Debug,CheckUnemployed,ShowHistogram : Boolean;
    TextOutput : TStringlist;
    PlotInput,PlotPar,PlotTxt,PlotRpt,ExPlotPar,ExPlotTxt : TStringlist;
    Form1: TForm1;
    Hist : TMyHistogram;
    OptimalEffort,MinRho,MaxRho : Real;
    MaxFirmSize,MinFirmSize : Integer;
    UnemploymentWage,MaxWage,MinWage : Real;

implementation

uses AggregateDemand,LoadSaver, PlaybackSpeed, Script,MathRoutines;

{$R *.DFM}

Constructor GoodsSegment.Init(GoodsInSeg,SegOwner,SegNumber : Integer);
var
    R : Real;
    I : Integer;
begin
    inherited Create;
    GSOwner := SegOwner;
    GSSegNumber := SegNumber;
    GSNumGoods := GoodsInSeg;
    if GSNumGoods < 2 then begin
	ShowMessage('Error in GoodsSegment');
	Halt;
    end;
    SetLength(GSGoodIndex,GSNumGoods+1);
    R := MinElSubst + (MaxElSubst-MinElSubst)*Random; {generate a new elasticity between minelsubst and maxelsubst}
    GSGamma := (R-1)/R;{compute gamma}
    SetLength(GSShare,1+GSNumGoods);
    R := 0;
    for I := 1 to GSNumGoods do begin  {initialize the weight for eahc good in the segment}
	GSShare[I] := Random;
	R := R + GSShare[I];
    end;
    for I := 1 to GSNumGoods do GSShare[I] := GSShare[I]/R;{normalize weight for each good so: sum(weight) = 1 }

end;

Destructor GoodsSegment.Free;
begin
    GSGoodIndex := Nil;
    GSShare := Nil;
    inherited Destroy;
end;

Procedure GoodsSegment.GetOptimalDemandForSegment; {Compute the optimal demand for the each good of one segment follow eq (7)}
var
    I,J,K : Integer;
    R : Real;
    F : Array of RealArray;
begin
    SetLength(F,GSNumGoods+1);
    for I := 1 to GSNumGoods do SetLength(F[I],GSNumGoods+1);
    for I := 1 to GSNumGoods do
	for J := 1 to GSNumGoods do
	    F[I,J] := Power(GSShare[J]/(GSShare[I]),1/(1-GSGamma)); 
    for I := 1 to GSNumGoods do begin
	    R := 0;
	    for J := 1 to GSNumGoods do R := R + F[I,J];
	    K := GSGoodIndex[I];
	    Workers[GSOwner].WDemand[K] := Workers[GSOwner].ShareSeg[GSSegNumber]/R; { bizarre les prix disparaisse entre ces equations et (7) ET (8)R=( }
    end;
    F := nil;
end;

    Constructor Worker.Init(I : Integer);
var
    J,K,L : Integer;
    TShare : Real;
    Shuffle : Array of Integer;
begin
    inherited Create;
    SetLength(WDemand,NumGoods+1);
    SetLength(PriceHistory,NumGoods+1);
    PriceHPointer := 1;
    for J := 1 to NumGoods do begin
	SetLength(PriceHistory[J],PriceHistoryLength+1);
	for K := 1 to PriceHistoryLength do PriceHistory[J,K] := MaxPrice
    end;
    SetLength(WSupplier,NumGoods+1);
    SetLength(WPrice,NumGoods+1);
    WIndex := I;
    DUEffort := AXMin + Random*(AXMax-AXMin);
    Rho := MinRho + Random*(MaxRho-MinRho);
    Delta := 1/(1+Rho);
    EZ := InitialEZ;
    Employed := False;
    NumSegments := Random(NumGoods div 2); {initialize the number of segment [1,ngoods/2]}

    if NumSegments = 0 then Inc(NumSegments);

    SetLength(Segments,NumSegments+1);
    SetLength(ShareSeg,NumSegments+1); 
    TShare := 0;
    for J := 1 to NumSegments do begin
	ShareSeg[J] := Random;
	TShare := TShare + ShareSeg[J]; 
    end;

    for J := 1 to NumSegments do ShareSeg[J] := ShareSeg[J]/TShare;	{sum(ShareSeg)=1}

    SetLength(Shuffle,1+NumSegments);

    for J := 1 to NumSegments do Shuffle[J] := 2;

    for J := 1 to NumGoods-2*NumSegments do
	Inc(Shuffle[1+Random(NumSegments)]);
    for J := 1 to NumSegments do
	Segments[J] := GoodsSegment.Init(Shuffle[J],WIndex,J);
    SetLength(Shuffle,NumGoods+1);
    for J := 1 to NumGoods do Shuffle[J] := J;
    for J := 1 to NumSegments do 
    	for K := 1 to Segments[J].GSNumGoods do begin
    	    L := 1 + Random(NumGoods);
    	    while Shuffle[L] = 0 do begin
    	        Inc(L);
    	        if L > NumGoods then L := 1;
    	    end;
    	    Segments[J].GSGoodIndex[K] := L;
    	    Shuffle[L] := 0;
    	end;
    SetLength(NumProbes,NumGoods+1);
    for J := 1 to NumGoods do
	NumProbes[J] := MinProbes + Random(MaxProbes-MinProbes);
    SetLength(OptimalConsumption,NumGoods+1);
    Shuffle := nil;
end;
;
Destructor Worker.Free;
var
    I : Integer;
begin
    WDemand := Nil;
    PriceHistory := Nil;
    WSupplier := Nil;
    WPrice := Nil;
    ShareSeg := Nil;
    for I := 1 to NumSegments do Segments[I].Free;
    Segments := Nil;
    OptimalConsumption := Nil;
    inherited Destroy;
end;

Constructor Good.Init(I : Integer);
begin
    GIndex := I;
    OptimalEmployees := KStar;
    MaxEmployees := NumWorkers div NumGoods;
    if I > NumGoods then Exit;
    if Assigned(Micrograph[I]) then MicroGraph[I].Destroy;
    if Assigned(Macrograph[I]) then MacroGraph[I].Destroy;
    MicroGraph[I] := TXYGraph.Create(Form1);
    MacroGraph[I] := TXYGraph.Create(Form1);
    InitializeMacroGraph;
    InitializeMicroGraph;
end;

Destructor Good.Destroy;
begin
    inherited Destroy;
end;

Procedure TForm1.Delay(Num: Cardinal);
var
    TC : Cardinal;
begin
    TC := GetTickCount;
    repeat
	Application.ProcessMessages;
    until GetTickCount- TC >= Num;
end;

Function TForm1.PricesStdDev;
var
    I : Integer;
    Ave,R : Real;
begin
    Ave := 0;
    for I := 1 to NumGoods do Ave := Ave + Goods[I].PriceAve.Ave;
    Ave := Ave/NumGoods;
    R := 0;
    for I := 1 to NumGoods do R := R +
    (Goods[I].PriceAve.Ave-Ave)*(Goods[I].PriceAve.Ave-Ave);
    PricesStdDev := Sqrt(R/NumGoods);
end;

Function DFC(R : Extended) : Extended;
var
    I,J : Integer;
    DFCValue,Rt : Extended;
begin
    DFCValue := 0;
    for I := 1 to NumGoods do 
    for J := 1 to Goods[I].NumFirms do begin
	Rt := Firms[I,J].DemandForCapital(R);
	if Rt > 0 then DFCValue := DFCValue + Rt;
    end;
    DFC := CapitalSupply - DFCValue;
end;

Procedure TForm1.AllocateCapital;
var
    Valid : Boolean;
    RMin,RMax : Real;
    I,J : Integer;
begin
    RMin := 1;
    while DFC(RMin) > 0 do RMin := RMin/2;
    RMax := RMin;
    while DFC(RMax) < 0 do RMax := RMax+1;
    CapitalRentalPriceAve.Add(GetNRRoot(DFC,RMin,RMax,0.1,Valid));
    if not Valid then begin
	ShowMessage('GetNRRoot not Valid!');
	Halt;
    end;
    CapitalRentalPrice := CapitalRentalPriceAve.Ave;
    for I := 1 to NumGoods do
	for J := 1 to Goods[I].NumFirms do 
    if Firms[I,J].DemandForCapital(CapitalRentalPrice) > 0 then
	Firms[I,J].Capital := Firms[I,J].DemandForCapital(CapitalRentalPrice)
    else Firms[I,J].Capital := 0;
end;

Procedure TForm1.PriceAdjust;
var
    I,J : Integer;
begin
    for I := 1 to NumGoods do begin
	for J := 1 to Goods[I].NumFirms do begin
	    if (Firms[I,J].Inventory > 0) and
	    (Firms[I,J].Price > Firms[I,J].PriceFloor) then
		Firms[I,J].Price :=
	    Firms[I,J].Price*Firms[I,J].PriceAdjustCoefficient
	else Firms[I,J].Price :=
	Firms[I,J].Price/Firms[I,J].PriceAdjustCoefficient;
	Goods[I].PriceAve.Add(Firms[I,J].Price);
    end;
end;
end;

Function Firm.DiddleValue(R : Real) : Real;
begin
    if Random < 0.5 then DiddleValue := R*DiddleAdjust
else DiddleValue := R/DiddleAdjust;
end;

Function Firm.EstimateEZ : Real;
var
    FEZ,P,W,Q,U,FDelta : Real;
begin
    if Form1.ZeroFallbackBox.Checked then begin
	EstimateEZ := UnemploymentWage/((MaxRho+MinRho)/2);
	Exit;
    end;
    if (TotalEmployed = NumWorkers) or (TotalEmployed = 0) or
    (TotalEmployedAve.Ave = 0) then begin
	EstimateEZ := (MaxWage+MinWage)/2;
	Exit;
    end;
    P := FoundEmploymentAve.Ave*1.0/(NumWorkers-TotalEmployedAve.Ave);
    Q := 1-LostEmploymentAve.Ave*1.0/TotalEmployedAve.Ave;
    U := UnemploymentWage;
    W := Goods[Product].WageAve.Ave - ((AXMax+AXMin)/2)/(1-CEffort);
    FDelta := 1/(1+(MaxRho+MinRho)/2);
    FEZ := (U*(1-FDelta*Q)+P*W*FDelta)/((1-FDelta)*(1+FDelta*(P-Q)));
    FirmEstEZAve.Add(FEZ);
    EstimateEZ := FirmEstEZAve.Ave;
end;

// This maximizes N*Sqrt(1 + 0.1*Capital) - R*Capital
// See ProductEffort and Output
Function Firm.DemandForCapital(R: Real) : Real;
var
    N : Integer;
begin
    N := Round(NextWorker*(2*KStar-NextWorker)/KStar/KStar);
    DemandForCapital := NextWorker*CEffort*(N*Price)*(N*Price)/40/(R*R) - 10;
end;

Constructor Firm.Init(Copy : Boolean;G : Good);
begin
    inherited Create;
    Product := G.GIndex;
    NextWorker := 0;
    Capital := 0;
    SetLength(WW,G.MaxEmployees+1);
    if Copy then begin
	TargetEmployment := Round(G.TargetEmploymentAve.Ave);
	if Random < 0.3 then Inc(TargetEmployment)
    else if Random < 0.3 then
	TargetEmployment := 1 + (3*Random(G.OptimalEmployees) div 2)
    else if TargetEmployment > 2 then Dec(TargetEmployment);
    CEffort := DiddleValue(G.CEffortAve.Ave);
    if CEffort > 0.999 then CEffort := 0.999;
    if Random < 0.3 then Wage := DiddleValue(G.WageAve.Ave)
else if Random < 0.3 then Wage := Goods[1+Random(NumGoods)].WageAve.Ave
    else Wage := ((MaxRho+MinRho)/2)*EstimateEZ +
    ((AXMax+AXMin)/2)/(1-CEffort)/(1-TaxRate);
    Price := DiddleValue(G.PriceAve.Ave);
    PriceAdjustCoefficient := DiddleValue(PriceAdjustCoefficientAve.Ave);
    if PriceAdjustCoefficient > 0.999 then PriceAdjustCoefficient := 0.999;
    FirmAdjustCoefficient := DiddleValue(FirmAdjustCoefficientAve.Ave);
    if FirmAdjustCoefficient > 0.999 then FirmAdjustCoefficient := 0.999;
end
else begin
    if Form1.ShockBox.Checked then TargetEmployment := KStar
else TargetEmployment := 1 + (3*Random(G.OptimalEmployees) div 2);
if Form1.ShockBox.Checked then CEffort := 0.95
    else CEffort := 0.9 + 0.09*Random;
    Wage := Random*(MaxWage-MinWage)+ MinWage;
    Price := Random*(MaxPrice-MinPrice)+ MinPrice;
    if ExtremeInitialize and (Periods <10) then begin
	Wage := Wage/25;
	Price := Price*25;
    end;
    PriceAdjustCoefficient := Form1.InitializePriceAdjust;
    FirmAdjustCoefficient := Form1.InitializeFirmAdjust;
end;
end;

Destructor Firm.Destroy;
begin
    inherited Destroy;
end;

Function Firm.ProductEffort(GI:Integer;Employees:Integer) : Real;
var
    R : Real;
begin
    R := Employees*(2*Goods[GI].OptimalEmployees-Employees)/
    Goods[GI].OptimalEmployees/Goods[GI].OptimalEmployees;
    ProductEffort := R*Sqrt(1+0.1*Capital);
end;

Procedure Firm.DismissWorker(I : Integer);
var
    J : Integer;
begin
    for J := 0 to NextWorker-1 do
	if WW[J] = I then Break;
    if J = NextWorker then begin
	ShowMessage('Error in DismissWorker');
	Halt;
    end;
    Workers[WW[J]].Employed := False;
    Dec(NextWorker);
    WW[J] := WW[NextWorker];
    Inc(LostEmployment);
end;

Function Worker.DiddleValue(R : Real) : Real;
begin
    if Random < 0.5 then DiddleValue := R*WorkerAdjustCoefficient
else DiddleValue := R/WorkerAdjustCoefficient;
end;

Procedure Worker.GetSuppliersAndPrices;
var
    I,J,K,L,Probes : Integer;
    Prices : RealArray;
    Indices,Unused : IndexArray;
    Found : Boolean;
begin
    for I := 1 to NumGoods do begin 
    Found := False;
    WSupplier[I] := 1;
    WPrice[I] := Firms[I,1].Price;
    if NumProbes[I] > Goods[I].NumFirms then Probes := Goods[I].NumFirms
else Probes := NumProbes[I];
SetLength(Prices,Probes+1);
SetLength(Indices,Probes+1);
SetLength(Unused,Goods[I].NumFirms+1);
for J := 1 to Goods[I].NumFirms do Unused[J] := J;
for J := 1 to Probes do begin
    K := 1 + Random(Goods[I].NumFirms);
    L := K;
    while (Unused[K] = 0) or (Firms[I,K].Inventory = 0) do begin
	Inc(K);
	if K > Goods[I].NumFirms then K := 1;
	if K = L then Break;
    end;
    Indices[J] := K;
    Unused[K] := 0;
    if Firms[I,K].Inventory = 0 then Prices[J] := MaxInt
else Prices[J] := Firms[I,K].Price;
    end;
    QuickSort(1,Probes,Prices,Indices);
    for J := Probes downto 1 do begin
	if Firms[I,Indices[J]].Inventory > 0 then begin
	    WSupplier[I] := Indices[J];
	    WPrice[I] := Prices[J];
	    PriceHistory[I,PriceHPointer] := WPrice[I];
	    Inc(PriceHPointer);
	    if PriceHPointer > PriceHistoryLength then PriceHPointer := 1;
	    Found := True;
	    Break;
	end;
    end;
    if not Found then begin
	K := 1 + Random(Goods[I].NumFirms);
	J := K;
	repeat
	    if Firms[I,K].Inventory > 0 then Break;
	    Inc(K);
	    if K > Goods[I].NumFirms then K := 1;
	until J = K;
	WSupplier[I] := K;
	WPrice[I] := Firms[I,K].Price;
	PriceHistory[I,PriceHPointer] := WPrice[I];
	Inc(PriceHPointer);
	if PriceHPointer > PriceHistoryLength then PriceHPointer := 1;
    end;
end;
end;

Procedure Worker.Shop;
var
    PriceLimit,LDemand : Real;
    I,J : Integer;
    F : Firm;
begin
    for I := 1 to NumGoods do begin
	PriceLimit := MaxInt;
	for J := 1 to PriceHistoryLength do
	    if PriceHistory[I,J] > PriceLimit then PriceLimit := PriceHistory[I,J];
	F := Firms[I,WSupplier[I]];
	if (F.Inventory > 0) and (WPrice[I] <= 1.2*PriceLimit) then begin
	    LDemand := Min(F.Inventory,WDemand[I]);
	    if Assigned(Consumption) then Consumption[I].Add(LDemand);
	    F.Inventory := F.Inventory - LDemand;
	    F.Profit := F.Profit + F.Price*LDemand;
	    Wealth := Wealth - F.Price*LDemand;
	end
	else WDemand[I] := 0;
    end;
end;

Procedure Worker.GetDemand;
var
    I : Integer;
begin
    for I := 1 to NumSegments do Segments[I].GSGetDemand;
end;

Procedure Worker.Quit;
var
    J : Integer;
begin
    for J := 0 to Firms[Industry,Employer].NextWorker-1 do
	if Firms[Industry,Employer].WW[J] = WIndex then Break;
    if J = Firms[Industry,Employer].NextWorker then begin
	ShowMessage('Error in Quit');
	Exit;
    end;
    if (Firms[Industry,Employer].NextWorker = 1) and
    (Goods[Industry].NumFirms > 2) then Goods[Industry].DropEmployer(Employer)
else begin
    Dec(Firms[Industry,Employer].NextWorker);
    Firms[Industry,Employer].WW[J] :=
    Firms[Industry,Employer].WW[Firms[Industry,Employer].NextWorker];
end;
Employed := False;
Inc(LostEmployment);
end;

Procedure Worker.SwitchEmployer(J,K : Integer);
begin
    Firms[Industry,Employer].DismissWorker(WIndex);
    Goods[J].Employ(K,WIndex,Firms[J,K].CEffort)
end;

Function Worker.ConsumptionUtility : Real; {ShareSeg = f it's not a function (a power function) but a WEIGHT}
var
    R,R1 : Real;
    I : Integer;
begin
    R := 1;
    for I := 1 to NumSegments do begin
	R1 := ShareSeg[I]*Segments[I].GSUtility;
	if R1 > 0 then R := R*R1;
    end;
    ConsumptionUtility := R;
end;

Function Good.HireWorker(LWage,LCEffort : Real;NewEmployer : Integer) :
    Integer;
var
    I,J : Integer;
    Found : Boolean;
    F : Firm;
begin
    HireWorker := 0;
    Found := False;
    I := Random(NumWorkers) + 1;
    J := I;
    if CheckUnemployed then while True do begin
	if (not Workers[I].Employed) and
	Workers[I].BeatsFallback(
	LWage*(1-TaxRate)-Workers[I].DUEffort/(1-LCEffort)) then begin
	    Found := True;
	    Break;
	end;
	Inc(I);
	if I > NumWorkers then I := 1;
	if I = J then Break;
    end;
    if not Found then begin
	CheckUnemployed := False;
	while True do begin
	    if Workers[I].Employed and ((Workers[I].Industry <> GIndex) or
	    (Workers[I].Employer <> NewEmployer)) then begin
		F := Firms[Workers[I].Industry,Workers[I].Employer];
		if LWage*(1-TaxRate) - Workers[I].DUEffort/(1-LCEffort) >
		F.Wage*(1-TaxRate)- Workers[I].DUEffort/(1-F.CEffort) then begin
		    Found := True;
		    Break;
		end;
	    end;
	    Inc(I);
	    if I > NumWorkers then I := 1;
	    if I = J then Exit;
	end;
    end;
    if Found then begin
	HireWorker := I;
	if Workers[I].Employed then
	    Firms[Workers[I].Industry,Workers[I].Employer].DismissWorker(I)
	else Inc(FoundEmployment);
    end;
end;

Procedure Good.AdjustEmployees;
const
    AdjustRate = 0.05;
var
    I,J,K,L : Integer;
    F : Firm;
begin
    for I := 1 to NumFirms do begin
	F := Firms[GIndex,I];
	if (F.Inventory = 0) and (F.NextWorker < F.TargetEmployment) then begin
	    CheckUnemployed := True;
	    K := F.TargetEmployment-F.NextWorker;
	    for L := 1 to K do begin
		J := HireWorker(F.Wage,F.CEffort,I);
		if J > 0 then Employ(I,J,F.CEffort)
	    else begin
		if Random < 0.5 then F.CEffort := F.CEffort*F.FirmAdjustCoefficient
	    else F.Wage := F.Wage/F.FirmAdjustCoefficient;
	    Break;
	end;
    end;
end;
  end;
end;

Procedure Good.AdjustEmployer;
const
    Tries = 5;
    AdjustRate = 0.05;
var
    I,J,K,L : Integer;
    F : Firm;
begin
    for I := 1 to NumWorkers do begin
	if Workers[I].Employed then begin
	    F := Firms[Workers[I].Industry,Workers[I].Employer];
	    if Random < AdjustRate then
		if not Workers[I].BeatsFallback(
	    F.Wage*(1-TaxRate)-Workers[I].DUEffort/(1-F.CEffort)) then
		Workers[I].Quit;
	end;
    end;
    for I := 1 to NumWorkers do begin
	if Workers[I].Employed then begin
	    F := Firms[Workers[I].Industry,Workers[I].Employer];
	    for L := 1 to Tries do begin
		J := 1 + Random(NumGoods);
		K := 1 + Random(Goods[J].NumFirms);
		if Firms[J,K].NextWorker < Firms[J,K].TargetEmployment then begin
		    if Firms[J,K].Wage*(1-TaxRate)-Workers[I].DUEffort/(1-Firms[J,K].CEffort) >
		    F.Wage*(1-TaxRate)-Workers[I].DUEffort/(1-F.CEffort) then begin
			Workers[I].SwitchEmployer(J,K);
			Break;
		    end
		end;
	    end;
	end;
    end;
end;

const
    AFMakeCopy = True;
    Procedure Good.AddFirm(CopyExisting : Boolean);
var
    I,J : Integer;
    F : Firm;
begin
    F := Firm.Init(CopyExisting,Self);
    Inc(NumFirms);
    SetLength(Firms[GIndex],NumFirms+1);
    Firms[GIndex,NumFirms] := F;
    CheckUnemployed := True;
    for I := 1 to F.TargetEmployment do begin
	J := HireWorker(F.Wage,F.CEffort,NumFirms);
	if J = 0 then Break;
	Employ(NumFirms,J,F.CEffort);
    end;
end;

Procedure Good.DropEmployer(I : Integer);
var
    J : Integer;
begin
    Firms[GIndex,I].Destroy;
    for J := 1 to NumWorkers do begin 
    if Workers[J].Employed and (Workers[J].Industry = GIndex) then begin
	if Workers[J].Employer = I then Workers[J].Employed := False
    else if Workers[J].Employer = NumFirms then Workers[J].Employer := I;
end;
  end;
  Firms[GIndex,I] := Firms[GIndex,NumFirms];
  Dec(NumFirms);
end;

Procedure Good.DropAFirm;
var
    Profits : RealArray;
    Indices : IndexArray;
    I : Integer;
begin
    SetLength(Profits,NumFirms+1);
    SetLength(Indices,NumFirms+1);
    for I := 1 to NumFirms do begin
	Profits[I] := Firms[GIndex,I].Profit;
	Indices[I] := I;
    end;
    QuickSort(1,NumFirms,Profits,Indices);
    DropFirm(Indices[NumFirms]);
    Profits := nil;
    Indices := nil;
end;

Function Good.DropOneFirm : Boolean;
begin
    DropOneFirm := NumFirms > 2;
end;

Function Good.AddOneFirm : Boolean;
begin
    AddOneFirm := (AveProfit > 0);
end;

Procedure Good.DropFirm(I : Integer);
var
    J : Integer;
begin
    Goods[GIndex].ProfitAve.Add(Firms[GIndex,I].Profit/Goods[GIndex].NumFirms);
    Firms[GIndex,I].Destroy;
    for J := 1 to NumWorkers do begin 
    if Workers[J].Employed and (Workers[J].Industry = GIndex) then begin
	if Workers[J].Employer = I then begin
	    Workers[J].Employed := False;
	    Inc(LostEmployment);
	end
	else if Workers[J].Employer = NumFirms then Workers[J].Employer := I;
    end;
end;
Firms[GIndex,I] := Firms[GIndex,NumFirms];
Dec(NumFirms);
end;

Procedure Good.Employ(F,W: Integer;CLEffort : Real);
begin
    Workers[W].Employer := F;
    Workers[W].Industry := GIndex;
    Workers[W].Employed := True;
    Firms[GIndex,F].WW[Firms[GIndex,F].NextWorker] := W;
    Inc(Firms[GIndex,F].NextWorker);
end;

Procedure Firm.LayoffWorker;
var
    J : Integer;
begin
    if NextWorker = 0 then Exit;
    J := Random(NextWorker);
    Workers[WW[J]].Employed := False;
    Dec(NextWorker);
    WW[J] := WW[NextWorker];
    Inc(LostEmployment);
end;

Procedure TForm1.Mutate;
const
    MicroMutationRate = 0.99;
var
    I,J : Integer;
begin
    for I := 1 to NumGoods do
	for J := 1 to Goods[I].NumFirms do begin
	    if Random < FirmMutationRate then begin
		if Random < MicroMutationRate then
		    Firms[I,J].Wage := Firms[I,J].DiddleValue(Firms[I,J].Wage)
		else Firms[I,J].Wage := Random*(MaxWage-MinWage)+ MinWage;
		if Random < MicroMutationRate then Firms[I,J].Price :=
		Firms[I,J].DiddleValue(Firms[I,J].Price)
	    else Firms[I,J].Price := Random*(MaxPrice-MinPrice)+ MinPrice;
	    if Random < MicroMutationRate then Firms[I,J].PriceAdjustCoefficient :=
	    Firms[I,J].DiddleValue(Firms[I,J].PriceAdjustCoefficient)
	else Firms[I,J].PriceAdjustCoefficient := InitializePriceAdjust;
	if Firms[I,J].PriceAdjustCoefficient > 0.999 then
	    Firms[I,J].PriceAdjustCoefficient := 0.999;
	if Random < MicroMutationRate then
	    Firms[I,J].CEffort := Firms[I,J].DiddleValue(Firms[I,J].CEffort)
	else Firms[I,J].CEffort := 0.99*Random;
	if Firms[I,J].CEffort > 0.999 then Firms[I,J].CEffort := 0.999;
	if Random < 0.5 then Inc(Firms[I,J].TargetEmployment)
    else if Firms[I,J].TargetEmployment > 2 then Dec(Firms[I,J].TargetEmployment);
end;
  end;
end;

var
    NumF,FSize,FEmployee : Array of Integer;
    CEff,FPrice,FCapital,FPriceAdjustCoefficient,
    FFirmAdjustCoefficient: Array of Real;

    Procedure InitGetFirmStats;
begin
    SetLength(NumF,NumGoods+1);
    SetLength(FSize,NumGoods+1);
    SetLength(FEmployee,NumGoods+1);
    SetLength(CEff,NumGoods+1);
    SetLength(FPrice,NumGoods+1);
    SetLength(FCapital,NumGoods+1);
    SetLength(FPriceAdjustCoefficient,NumGoods+1);
    SetLength(FFirmAdjustCoefficient,NumGoods+1);
end;

Procedure TForm1.GetFirmStats;
var
    I,J : Integer;
begin
    for I := 1 to NumGoods do begin
	NumF[I] := 0;FSize[I] := 0;CEff[I] := 0;FEmployee[I] := 0;
	FPrice[I] := 0;FCapital[I] := 0;
	FPriceAdjustCoefficient[I] := 0;FFirmAdjustCoefficient[I] := 0;
    end;
    for I := 1 to NumGoods do begin
	for J := 1 to Goods[I].NumFirms do begin 
	Inc(NumF[I]);
	FSize[I] := FSize[I] + Firms[I,J].TargetEmployment;
	CEff[I] := CEff[I] + Firms[I,J].CEffort;
	FPrice[I] := FPrice[I] + Firms[I,J].Price;
	FCapital[I] := FCapital[I] + Firms[I,J].Capital;
	FPriceAdjustCoefficient[I] := FPriceAdjustCoefficient[I] +
	Firms[I,J].PriceAdjustCoefficient;
	FFirmAdjustCoefficient[I] := FFirmAdjustCoefficient[I] +
	Firms[I,J].FirmAdjustCoefficient;
	Inc(FEmployee[I],Firms[I,J].NextWorker-1);
    end;
end;
for I := 1 to NumGoods do begin
    Goods[I].TargetEmploymentAve.Add(FSize[I]/NumF[I]);
    Goods[I].PriceAve.Add(FPrice[I]/NumF[I]);
    Goods[I].CapitalAve.Add(FCapital[I]/NumF[I]);
    PriceAdjustCoefficientAve.Add(FPriceAdjustCoefficient[I]/NumF[I]);
    FirmAdjustCoefficientAve.Add(FFirmAdjustCoefficient[I]/NumF[I]);
    Goods[I].NumFirmsAve.Add(NumF[I]);
    Goods[I].EmployeeAve.Add(FEmployee[I]/NumF[I]);
    Goods[I].CEffortAve.Add(CEff[I]/NumF[I]);
end;
end;

Procedure TForm1.NewFallbacks;
var
    I,J : Integer;
    D,P,W,Q,U : Real;
begin
    if TotalEmployed = NumWorkers then Exit;
    if ZeroFallbackBox.Checked then begin
	for I := 1 to NumWorkers do
	    Workers[I].EZ := UnemploymentWage/Workers[I].Rho;
	Exit;
    end;
    P := FoundEmploymentAve.Ave*1.0/(NumWorkers-TotalEmployedAve.Ave);
    Q := 1-LostEmploymentAve.Ave*1.0/TotalEmployedAve.Ave;
    U := UnemploymentWage;
    for I := 1 to NumWorkers do begin
	W := 0;
	for J := 1 to NumGoods do
	    W := W + Goods[J].WageAve.Ave -
	Workers[I].DUEffort/(1-Goods[J].EffortAve.Ave);
	W := W/NumGoods;
	D := Workers[I].Delta;
	Workers[I].EZ := (U*(1-D*Q)+P*W*D)/((1-D)*(1+D*(P-Q)));
    end;
end;

Procedure TForm1.InitializeEmployment;
var
    I,J,K,L : Integer;
begin
    for I := 1 to NumGoods do begin
	for J := 1 to Goods[I].NumFirms do begin
	    CheckUnemployed := True;
	    for K := 1 to Firms[I,J].TargetEmployment do begin
		L := Goods[I].HireWorker(Firms[I,J].Wage,Firms[I,J].CEffort,J);
		if L > 0 then Goods[I].Employ(J,L,Firms[I,J].CEffort)
	    else Break;
	end;
    end
end;
end;

Procedure TForm1.InitializeAssetDistribution;
var
    I : Integer;
    R,TK : Real;
begin
    TK := 0;
    for I := 1 to NumWorkers do begin
	R := Random;
	TK := R + TK;
	Workers[I].KAsset := R;
    end;
    for I := 1 to NumWorkers do
	Workers[I].KAsset := Workers[I].KAsset*CapitalSupply/TK;
end;

Procedure TForm1.GetWorkerStats;
var
    I : Integer;
begin
    for I := 1 to NumGoods do
	if Goods[I].TEmployed > 0 then
	    Goods[I].EffortAve.Add(Goods[I].TEffort/Goods[I].TEmployed);
	FoundEmploymentAve.Add(FoundEmployment);
	LostEmploymentAve.Add(LostEmployment);
	TotalEmployedAve.Add(TotalEmployed);
    end;

    Procedure Good.GetNextFirmGeneration;
var
    I,J,K,L,NewFirms: Integer;
    Profits : RealArray;
    Indices : IndexArray;
begin
    I := 1;
    while I <= NumFirms do begin
	if Firms[GIndex,I].NextWorker < 2 then DropFirm(I)
    else Inc(I);
end;
// Try dropping this line
while NumFirms < MinFirms do AddFirm(not AFMakeCopy);
NewFirms := Round(NumFirms*FirmReplacementRate);
if NewFirms = 0 then begin
    if NumFirms < 2 then Exit;
    Inc(NewFirms);
end;
SetLength(Profits,NumFirms+1);
SetLength(Indices,NumFirms+1);
AveWage := 0;
AveProfit := 0;
for I := 1 to NumFirms do begin
    AveWage := AveWage + Firms[GIndex,I].Wage;
    AveProfit := AveProfit + Firms[GIndex,I].Profit;
    Profits[I] := Firms[GIndex,I].Profit;
    Indices[I] := I;
end;
QuickSort(1,NumFirms,Profits,Indices);
for I := 1 to NewFirms do begin
    K := Indices[NumFirms+1-I];
    J := Indices[I];
    CheckUnemployed := True;
    Firms[GIndex,K].Wage := Firms[GIndex,J].Wage;
    Firms[GIndex,K].Price := Firms[GIndex,J].Price;
    Firms[GIndex,K].PriceAdjustCoefficient :=
    Firms[GIndex,J].PriceAdjustCoefficient;
    Firms[GIndex,K].FirmAdjustCoefficient :=
    Firms[GIndex,J].FirmAdjustCoefficient;
    Firms[GIndex,K].TargetEmployment := Firms[GIndex,J].TargetEmployment;
    Firms[GIndex,K].CEffort := Firms[GIndex,I].CEffort;
    while Firms[GIndex,K].TargetEmployment>Firms[GIndex,K].NextWorker-1 do begin
	L := HireWorker(Firms[GIndex,K].Wage,Firms[GIndex,K].CEffort,K);
	if L = 0 then Exit;
	Employ(K,L,Firms[GIndex,K].CEffort);
    end;
    while Firms[GIndex,K].TargetEmployment < Firms[GIndex,K].NextWorker-1 do
	Firms[GIndex,K].LayoffWorker;
end;
WageAve.Add(AveWage/NumFirms);
ProfitAve.Add(AveProfit/NumFirms);
Profits := nil;
Indices := nil;
end;

Procedure TForm1.Produce;
var
    I,J,K : Integer;
    Output : Real;
begin
    for I := 1 to NumGoods do begin
	Goods[I].Supply := 0;
	Goods[I].AveEZ := 0;
	Goods[I].TEmployed := 0;
	for J := 1 to Goods[I].NumFirms do begin
	    Inc(Goods[I].TEmployed,Firms[I,J].NextWorker);
	    for K := 0 to Firms[I,J].NextWorker-1 do 
	    Goods[I].AveEZ := Goods[I].AveEZ + Workers[Firms[I,J].WW[K]].EZ;
	    Output := Firms[I,J].NextWorker*Firms[I,J].CEffort*
	    Firms[I,J].ProductEffort(I,Firms[I,J].NextWorker);
	    if Output > 0 then Firms[I,J].PriceFloor :=
	    (Firms[I,J].Wage*Firms[I,J].NextWorker +
		Firms[I,J].Capital*CapitalRentalPrice)/Output;
		Firms[I,J].Inventory :=
		DepreciationFactor*Firms[I,J].Inventory + Output;
		Goods[I].Supply := Goods[I].Supply + Firms[I,J].Inventory;
		Firms[I,J].Profit := - Firms[I,J].Wage*Firms[I,J].NextWorker
		- Firms[I,J].Capital*CapitalRentalPrice;
	    end;
	    if Goods[I].TEmployed > 0 then
		Goods[I].EZAve.Add(Goods[I].AveEZ/Goods[I].TEmployed);
	    Goods[I].SupplyAve.Add(Goods[I].Supply);
	    Goods[I].Demand := 0;
	end;
    end;

    Procedure TForm1.Pay;
var
    I : Integer;
    EarnedIncome,WorkEffort,TProfits : Real;
begin
    for I := 1 to NumGoods do begin
	Goods[I].TEffort := 0;
	Goods[I].TEmployed := 0;
    end;
    EarnedIncome := 0;
    TotalEmployed := 0;
    for I := 1 to NumWorkers do begin
	if Workers[I].Employed then begin
	    Inc(Goods[Workers[I].Industry].TEmployed);
	    Inc(TotalEmployed);
	    WorkEffort := Firms[Workers[I].Industry,Workers[I].Employer].CEffort;
	    Goods[Workers[I].Industry].TEffort := Goods[Workers[I].Industry].TEffort + WorkEffort;
	    Workers[I].CurrentIncome := Firms[Workers[I].Industry,Workers[I].Employer].Wage +
	    Workers[I].KAsset*CapitalRentalPrice;
	    Workers[I].Wealth := Workers[I].Wealth + Workers[I].CurrentIncome;
	    EarnedIncome := EarnedIncome + Workers[I].CurrentIncome;
	end;
    end;
    TProfits := 0;
    for I := 1 to NumGoods do TProfits := TProfits + Goods[I].AveProfit;
    if EarnedIncome = 0 then begin
	ShowMessage('There is zero employment!');
	Halt;
    end;
    for I := 1 to NumWorkers do begin
	if not Workers[I].Employed then begin
	    Workers[I].CurrentIncome := UnemploymentWage + Workers[I].KAsset*CapitalRentalPrice;
	    Workers[I].Wealth := Workers[I].Wealth + Workers[I].CurrentIncome;
	    EarnedIncome := EarnedIncome + Workers[I].CurrentIncome;
	end;
    end;
    TaxRate:=((NumWorkers-TotalEmployed)*UnemploymentWage-TProfits)/EarnedIncome;
    if TaxRate < 0 then TaxRate := 0;
    for I := 1 to NumWorkers do
	TotalIncome := TotalIncome + Workers[I].CurrentIncome;
    for I := 1 to NumWorkers do
	Workers[I].IncomeAve.Add(Workers[I].Wealth);
end;

Procedure TForm1.Sell;
var
    I,J,K : Integer;
begin
    I := 1 + Random(NumWorkers);
    J := I;
    repeat
	Workers[I].GetSuppliersAndPrices;
	Workers[I].GetDemand;
	for K := 1 to NumGoods do
	    Goods[K].Demand := Goods[K].Demand + Workers[I].WDemand[K];
	Workers[I].Shop;
	Inc(I);
	if I > NumWorkers then I := 1;
	if I = J then Break;
    until False;
    for I := 1 to NumGoods do Goods[I].DemandAve.Add(Goods[I].Demand);
end;

Function Worker.OptimalUtility;
var
    R,R1,OIncome : Real;
    I : Integer;
begin
    OIncome := Sqrt(1.67)*OptimalEffort;
    for I := 1 to NumGoods do begin
	WDemand[I] := OIncome*OptimalConsumption[I];
	AggOptConsumption[I] := AggOptConsumption[I] + WDemand[I];
    end;
    R := 1;
    for I := 1 to NumSegments do begin
	R1 := ShareSeg[I]*Segments[I].GSUtility;
	if R1 > 0 then R := R*R1;
    end;
    OptimalUtility := R;
end;

Procedure Worker.SetOptimalConsumption;
var
    J : Integer;
begin
    for J := 1 to NumSegments do Segments[J].GetOptimalDemandForSegment;
    // Corresponds to Wealth = 1
    for J := 1 to NumGoods do OptimalConsumption[J] := WDemand[J];
end;

Function Worker.InitialEZ : Real;
begin
    if Form1.ZeroFallbackBox.Checked then begin
	InitialEZ := UnemploymentWage/Rho;
	Exit;
    end;
    if Form1.ShockBox.Checked then InitialEZ := 40
    {// If this is too high, it takes forever for U to fall below 5%
    // If this is too low (e.g., 1.5->1), there is lots of price dispersion
    //  I don't know why.}
else  InitialEZ := UnemploymentWage*3*Random/Rho;
end;

Function Worker.BeatsFallback(Offer : Real) : Boolean;
begin
    BeatsFallback := Offer > Rho*EZ*(1-TaxRate);
end;

Procedure GoodsSegment.GSGetDemand; {equation (7) to determine the value x_i that a agent will ask. ;WPrices= p_i; ShareSeg=f_i; GSShare=alpha_i}
var
    I,J : Integer;
    R : Real;
    F : Array of RealArray;
begin
    SetLength(F,GSNumGoods+1);
    for I := 1 to GSNumGoods do SetLength(F[I],GSNumGoods+1);
    for I := 1 to GSNumGoods do
	for J := 1 to GSNumGoods do
	    F[I,J] := Power(GSShare[J]*Workers[GSOwner].WPrice[GSGoodIndex[I]]/
		(GSShare[I]*Workers[GSOwner].WPrice[GSGoodIndex[J]]),1/(1-GSGamma));
    for I := 1 to GSNumGoods do begin
    	R := 0;
    	for J := 1 to GSNumGoods do
		R := R + F[I,J]*Workers[GSOwner].WPrice[GSGoodIndex[J]]; {Down aprt of 7}
    	Workers[GSOwner].WDemand[GSGoodIndex[I]] := Workers[GSOwner].Wealth*Workers[GSOwner].ShareSeg[GSSegNumber]/R; 
    end;
	F := nil;
end;

var
    GS,R1,R2,R3 : Real;
    GSO : Integer;
    Function GoodsSegment.GSUtility;
var
    I : Integer;
    R : Real;
begin
    GS := GSGamma;
    if Abs(GSGamma) < 0.01 then begin // Cobb-Douglas
    R := 1;
    GSO := GSOwner;
    for I := 1 to GSNumGoods do begin
	R2 := Workers[GSOwner].WDemand[GSGoodIndex[I]];
	R3 := GSShare[I];
	R := R*Power(Workers[GSOwner].WDemand[GSGoodIndex[I]],GSShare[I]);
    end
end
else begin
    R := 0;
    for I := 1 to GSNumGoods do
	if Workers[GSOwner].WDemand[GSGoodIndex[I]] > 0 then
	    R := R + GSShare[I]*Power(Workers[GSOwner].WDemand[GSGoodIndex[I]],GSGamma);
	R1 := R; {useless?}
	if R > 0 then R := Power(R,1/GSGamma)
    end;
    GSUtility := R;
end;

Procedure TForm1.CheckAssignments;
var
    I,J,K : Integer;
begin
    for I := 1 to NumWorkers do begin
	if Workers[I].Employed then begin
	    for J := 0 to
	    Firms[Workers[I].Industry,Workers[I].Employer].NextWorker-1 do begin
		if Firms[Workers[I].Industry,Workers[I].Employer].WW[J] = I then Break;
	    end;
	    if J = Firms[Workers[I].Industry,Workers[I].Employer].NextWorker then begin
		ShowMessage('Error I in CheckAssignments');
		Exit;
	    end;
	end;
    end;
    for I := 1 to NumGoods do begin
	for J := 1 to Goods[I].NumFirms do begin
	    for K := 0 to Firms[I,J].NextWorker-1 do begin
		if not Workers[Firms[I,J].WW[K]].Employed then begin
		    ShowMessage('Error II in CheckAssignments');
		    Exit;
		end;
		if Workers[Firms[I,J].WW[K]].Industry <> I then begin
		    ShowMessage('Error III in CheckAssignments');
		    Exit;
		end;
		if Workers[Firms[I,J].WW[K]].Employer <> J then begin
		    ShowMessage('Error IV in CheckAssignments');
		    Exit;
		end;
	    end;
	end;
    end;
end;

Function TForm1.InitializePriceAdjust : Real;
begin
    InitializePriceAdjust := 0.95 + 0.05*Random;
end;

Function TForm1.InitializeFirmAdjust : Real;
begin
    InitializeFirmAdjust := 0.95 + 0.05*Random;
end;

var
    MicWageRate,MicEffort,MicEZ,MicProfits,MicURate : Integer;
    Procedure Good.InitializeMicroGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with MicroGraph[GIndex] do begin
	Caption := 'Good ' + IntToStr(GIndex) + ': ';
	Caption := Caption + 'Micro Data';
	Initialize(GraphWidth,GraphHeight, Form1.Left +
	    GraphWidth +HGap*(GIndex-1),3*(GIndex-1));
	    //    ShowGraph;
	    Visible := False;
	    SetVLabel('');
	    SetHLabel('Period');
	    MicWageRate := SetLegend('Wage Rate');
	    MicEffort := SetLegend('Effort Level');
	    MicProfits := SetLegend('Profits/100');
	    MicURate := SetLegend('Unemployment Rate');
	    if not Form1.ZeroFallbackBox.Checked then
		MicEZ := SetLegend('Worker Fallback/100');
	    SetXAfterDecimalPoint(0);
	    SetYAfterDecimalPoint(2);
	    SetXYLimits(CalibratePeriod,TotalPeriods,0,0.2);
	end;
    end;

    Procedure TForm1.InitializePriceGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
var
    I : Integer;
begin
    with PriceGraph do begin
	Caption := 'Prices-' + PCaption;
	Initialize(GraphWidth,GraphHeight,Form1.Left + 5,35);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	SetLegend('Standard Deviation of Prices');
	for I := 1 to NumGoods do
	    SetLegend('Price of Good ' + IntToStr(I));
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(2);
	SetXYLimits(CalibratePeriod,TotalPeriods,0,2);
    end;
end;

Procedure TForm1.InitializeEfficiencyGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with EfficiencyGraph do begin
	Caption := 'Efficiency-' + PCaption;
	Initialize(GraphWidth,GraphHeight,Form1.Left + 5,35);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	SetLegend('Efficiency of Economy');
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(2);
	SetXYLimits(CalibratePeriod,TotalPeriods,0,1);
    end;
end;

var
    PGCapRentalPrice : Integer;
    Procedure TForm1.InitializeCapitalPriceGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with CapitalPriceGraph do begin
	Caption := 'Capital Price-' + PCaption;
	Initialize(GraphWidth,GraphHeight,Form1.Left + 5,35);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	PGCapRentalPrice := SetLegend('Rental Price of Capital');
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(2);
	SetXYLimits(CalibratePeriod,TotalPeriods,0,0.3);
    end;
end;

Procedure TForm1.InitializeProfitsGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with ProfitsGraph do begin
	Caption := 'Profits';
	Initialize(GraphWidth,GraphHeight,Form1.Left + 5,75);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	SetLegend('Average Profits/GNP');
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(3);
	SetXYLimits(CalibratePeriod,TotalPeriods,-0.1,0.2);
    end;
end;

Procedure TForm1.InitializeWealthGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with WealthGraph do begin
	Caption := 'Wealth';
	Initialize(GraphWidth,GraphHeight,Form1.Left + 5,35);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	SetLegend('Average Wealth/GNP');
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(4);
	SetXYLimits(CalibratePeriod,TotalPeriods,-0.001,0.002);
    end;
end;

Procedure TForm1.InitializeAdjustGraph;
const
    GraphHeight = 300;GraphWidth = 550;
begin
    with AdjustGraph do begin
	Caption := 'Adjustment Parameters';
	Initialize(GraphWidth,GraphHeight,Form1.Left + 25,40);
	ShowGraph;
	SetVLabel('');
	SetHLabel('Period');
	SetLegend('Firm Price Adjust');
	SetLegend('Firm Wage,Effort Adjust');
	SetXAfterDecimalPoint(0);
	SetYAfterDecimalPoint(2);
	SetXYLimits(CalibratePeriod,TotalPeriods,0,1);
    end;
end;

Procedure Good.InitializeMacroGraph;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with MacroGraph[GIndex] do begin
	Caption := 'Good ' + IntToStr(GIndex) + ': ';
	Caption := Caption + 'Macro Data';
	Initialize(GraphWidth,GraphHeight,
	    Form1.Left + GraphWidth + HGap*(GIndex-1),GraphHeight+100+3*(GIndex-1));
	    //    ShowGraph;
	    Visible := False;
	    SetVLabel('');
	    SetHLabel('Period');
	    SetLegend('Supply/Worker/1000');
	    SetLegend('Demand/Worker/1000');
	    SetLegend('Target Employees/100');
	    SetLegend('Number of Firms/25');
	    SetLegend('Actual Employees/100');
	    SetXAfterDecimalPoint(0);
	    SetYAfterDecimalPoint(2);
	    SetXYLimits(CalibratePeriod,TotalPeriods,0,1);
	end;
    end;

    Procedure InitializeHistogram;
const
    GraphHeight = 300;
    GraphWidth = 550;
begin
    with Hist do begin
	Initialize(GraphWidth,GraphHeight,
	    Form1.Left+Form1.Width,GraphHeight+100);
	    ShowGraph;
	    SetVLabel('Fraction of Firms');
	    SetHLabel('Decile');
	    SetLegend(1,'');
	    SetXAfterDecimalPoint(0);
	    SetYAfterDecimalPoint(2);
	    SetXYLimits(1,NTiles,0,10,1,NTiles,8);
	end;
    end;

    Procedure TForm1.LaborShock;
var
    J,K : Integer;
begin
    Inc(NumWorkers,1000);
    SetLength(Workers,NumWorkers+1);
    for J := NumWorkers-1000+1 to NumWorkers do begin
	Workers[J] := Worker.Init(J);
	Workers[J].SetOptimalConsumption;
	SetLength(Workers[J].Consumption,NumGoods+1);
	for K := 1 to NumGoods do
	    Workers[J].Consumption[K] := TRAverage.Init(Vision);
	Workers[J].IncomeAve := TRAverage.Init(Vision);
	Workers[J].AverageWage := TRAverage.Init(Vision);
    end;
end;

Procedure TForm1.CapitalShock;
var
    J,K : Integer;
begin
    OldIntValue1 := KStar;
    KStar := Round(KStar*0.4);
    for J := 1 to NumGoods do with Goods[J] do
	for K := 1 to NumFirms do with Firms[J,K] do
	    OptimalEmployees := KStar;
	InShock := True;
	ShockIteration := 0;
    end;

    Procedure TForm1.CheckShock;
var
    J,K : Integer;
begin
    Inc(ShockIteration);
    if ShockIteration = ShockDuration then begin
	InShock := False;
	KStar := OldIntValue1;
	for J := 1 to NumGoods do with Goods[J] do
	    for K := 1 to NumFirms do with Firms[J,K] do
		OptimalEmployees := KStar;
	end;
    end;

    Procedure Good.DisplayHistogram;
var
    I,VMin,VMax : Integer;
    Bins : Array[1..NTiles] of Integer;
    F : Array of Integer;
begin
    SetLength(F,NumFirms+1);
    for I := 1 to NTiles do Bins[I] := 0;
    for I := 1 to NumFirms do F[I] := 0;
    for I := 1 to NumWorkers do 
    if Workers[I].Employed then Inc(F[Workers[I].Employer]);
    VMax := -1;
    VMin := 10000;
    for I := 1 to NumFirms do begin
	if F[I] < VMin then VMin := F[I];
	if F[I] > VMax then VMax := F[I];
    end;
    if VMax = VMin then Exit;
    for I := 1 to NumFirms do
	Inc(Bins[1+Round((NTiles-1)*(F[I]-VMin)/(VMax-VMin))]);
    with Hist do begin
	Clear;
	for I := 1 to NTiles do AddBar(1,I,Bins[I]);
    end;
    F := nil;
end;

Procedure TForm1.Calibrate;
var
    R : Real;
    J : Integer;
begin
    WageMin := MaxInt;
    WageMax := -MaxInt;
    for J := 1 to NumGoods do begin
	R := Goods[J].WageAve.Min;
	if WageMin > R then WageMin := R;
	R := Goods[J].WageAve.Max;
	if WageMax < R then WageMax := R;
    end;
    EffortMin := MaxInt;
    EffortMax := -MaxInt;
    for J := 1 to NumGoods do begin
	R := Goods[J].EffortAve.Min;
	if EffortMin > R then EffortMin := R;
	R := Goods[J].EffortAve.Max;
	if EffortMax < R then EffortMax := R;
    end;
    SDMin := MaxInt;
    SDMax := -MaxInt;
    for J := 1 to NumGoods do begin
	R := Goods[J].SupplyAve.Min;
	if SDMin > R then SDMin := R;
	R := Goods[J].SupplyAve.Max;
	if SDMax < R then SDMax := R;
    end;
    for J := 1 to NumGoods do begin
	R := Goods[J].DemandAve.Min;
	if SDMin > R then SDMin := R;
	R := Goods[J].DemandAve.Max;
	if SDMax < R then SDMax := R;
    end;
    NumFirmsMin := MaxInt;
    NumFirmsMax := -MaxInt;
    for J := 1 to NumGoods do begin
	R := Goods[J].NumFirmsAve.Min;
	if NumFirmsMin > R then NumFirmsMin := R;
	R := Goods[J].NumFirmsAve.Max;
	if NumFirmsMax < R then NumFirmsMax := R;
    end;
    EmployeeMin := MaxInt;
    EmployeeMax := -MaxInt;
    for J := 1 to NumGoods do begin
	R := Goods[J].EmployeeAve.Min;
	if EmployeeMin > R then EmployeeMin := R;
	R := Goods[J].EmployeeAve.Max;
	if EmployeeMax < R then EmployeeMax := R;
    end;
    for J := 1 to NumGoods do begin
	R := Goods[J].EmployeeAve.Min;
	if EmployeeMin > R then EmployeeMin := R;
	R := Goods[J].EmployeeAve.Max;
	if EmployeeMax < R then EmployeeMax := R;
    end;
    EZMin := 0;
    EZMax := 10;
    for J := 1 to NumGoods do begin
	R := Goods[J].EZAve.Min;
	if EZMin > R then EZMin := R;
	R := Goods[J].EZAve.Max;
	if EZMax < R then EZMax := R;
    end;
end;

Procedure CalculateAverageProfits;
var
    R,R1 : Extended;
    K : Integer;
begin
    R := 0;
    for K := 1 to NumGoods do
	R := R + Goods[K].ProfitAve.Ave*Goods[K].NumFirms;
    R1 := 0;
    for K := 1 to NumWorkers do R1 := R1 + Workers[K].CurrentIncome;
    AverageProfits := AverageProfits + R/R1;
    Inc(AveProfDenom);
end;

Procedure CalculateAverageWealth;
var
    R,R1 : Extended;
    K : Integer;
begin
    R := 0;
    for K := 1 to NumWorkers do R := R + Workers[K].Wealth;
    R1 := 0;
    for K := 1 to NumWorkers do R1 := R1 + Workers[K].CurrentIncome;
    AverageWealth := AverageWealth + R/R1;
    Inc(AveWealthDenom);
end;

Procedure TForm1.DisplayResults;
var
    J,K : Integer;
    R,R1 : Real;
begin
    if Periods < 6*CalibratePeriod+1 then begin
	AverageProfits := 0;
	AveProfDenom := 1;
	AverageWealth := 0;
	AveWealthDenom := 1;
    end;
    for J := 1 to NumGoods do AggOptConsumption[J] := 0;
    R := 0;
    //Todo: Figure out why R1 > 1 in some cases
    for J := 1 to NumWorkers do begin
	R1 := Workers[J].ConsumptionUtility/Workers[J].OptimalUtility;
	if R1 < 1 then R := R + R1; {jsute utile pour calculer la moyenne de cette utilité normalizé}
    end;
    EfficiencyAve.Add(R/NumWorkers);
    with ReportForm do if Visible then begin
	UOverOptUBox.Text := Format('%*.*f',[6,6,R/NumWorkers]);
	W1Cons1Box.Text :=  Format('%*.*f',[6,3,Workers[1].Consumption[1].Ave]);
	if NumGoods > 1 then
	    W1Cons2Box.Text :=  Format('%*.*f',[6,3,Workers[1].Consumption[2].Ave])
	else W1Cons2Box.Color := clSilver;
	if NumGoods > 2 then begin
	    W1Cons3Box.Text := Format('%*.*f',[6,3,Workers[1].Consumption[3].Ave]);
	    W1Cons4Box.Text := Format('%*.*f',[6,3,Workers[1].Consumption[4].Ave]);
	end
	else begin
	    W1Cons3Box.Color := clSilver;
	    W1Cons4Box.Color := clSilver;
	end;
	RentalPriceofCapitalBox.Text :=
	Format('%*.*f',[6,3,CapitalRentalPrice]);
    end;
    If Assigned(ProfitsGraph) then begin
	CalculateAverageProfits;
	ProfitsGraph.AddPoint(1,Periods,AverageProfits/AveProfDenom);
	ProfitsGraph.AddPoint(2,Periods,0);
    end;
    If Assigned(WealthGraph) then begin
	CalculateAverageWealth;
	WealthGraph.AddPoint(1,Periods,AverageWealth/AveWealthDenom);
	WealthGraph.AddPoint(2,Periods,0);
    end;
    for J := 1 to NumGoods do begin
	with MicroGraph[J] do begin
	    AddPoint(MicWageRate,Periods,Goods[J].WageAve.Ave);
	    AddPoint(2,Periods,(Goods[J].EffortAve.Ave));
	    R := 0;
	    for K := 1 to NumGoods do R := R + Goods[K].EffortAve.Ave;
	    with ReportForm do
		if Visible then AveEffortBox.Text := Format('%*.*f',[6,3,R/NumGoods]);
	    Addpoint(MiCProfits,Periods,Goods[J].ProfitAve.Ave/100);
	    Addpoint(MiCURate,Periods,1-TotalEmployedAve.Ave/NumWorkers);
	    if not ZeroFallbackBox.Checked then
		AddPoint(MiCEZ,Periods,Goods[J].EZAve.Ave/100);
	end;
	with ReportForm do if Visible then begin
	    Good1WageBox.Text := Format('%*.*f',[6,2,Goods[J].WageAve.Ave]);
	    R := 0;
	    for K := 1 to NumGoods do R := R + Goods[K].EffortAve.Ave;
	    AveEffortBox.Text := Format('%*.*f',[6,3,R/NumGoods]);
	    Good1EffortBox.Text := Format('%*.*f',[6,2,Goods[J].EffortAve.Ave]);
	    if not ZeroFallbackBox.Checked then
		FallbackBox.Text := Format('%*.*f',[6,2,Goods[J].EZAve.Ave]);
	end;
	with MacroGraph[J] do begin
	    AddPoint(1,Periods,Goods[J].SupplyAve.Ave/1000);
	    AddPoint(2,Periods,Goods[J].DemandAve.Ave/1000);
	    AddPoint(3,Periods,Goods[J].TargetEmploymentAve.Ave/100);
	    AddPoint(4,Periods,Goods[J].NumFirmsAve.Ave/25);
	    AddPoint(5,Periods,Goods[J].EmployeeAve.Ave/100);
	end;
	with ReportForm do if Visible then begin
	    SupplyBox.Text := Format('%*.*f',[6,2,Goods[J].SupplyAve.Ave]);
	    DemandBox.Text := Format('%*.*f',[6,2,Goods[J].DemandAve.Ave]);
	    TargetEmploymentBox.Text := Format('%*.*f',[6,2,Goods[J].TargetEmploymentAve.Ave]);
	    NumFirmsBox.Text := Format('%*.*f',[6,2,Goods[J].NumFirmsAve.Ave]);
	    EmploymentBox.Text := Format('%*.*f',[6,2,Goods[J].EmployeeAve.Ave]);
	    Good1Firm1CapitalBox.Text := Format('%*.*f',[6,2,Firms[1,1].Capital]);
	end;
    end;
    If Assigned(PriceGraph) then with PriceGraph do begin
	for J := 1 to NumGoods do
	    AddPoint(J,Periods,(Goods[J].PriceAve.Ave));
	with ReportForm do if Visible then
	    Good1PriceBox.Text := Format('%*.*f',[6,2,Goods[1].PriceAve.Ave]);
	if ReportForm.ShowForm then ReportForm.Show;
    end;
    If Assigned(EfficiencyGraph) then
	EfficiencyGraph.AddPoint(1,Periods,EfficiencyAve.Ave);
    If Assigned(CapitalPriceGraph) then begin
	CapitalPriceGraph.AddPoint(1,Periods,CapitalRentalPriceAve.Ave);
	with ReportForm do if Visible then
	    CRPBox.Text := Format('%*.*f',[6,2,CapitalRentalPriceAve.Ave]);
	if ReportForm.ShowForm then ReportForm.Show;
    end;
    if Assigned(AdjustGraph) then with AdjustGraph do begin
	AddPoint(1,Periods,PriceAdjustCoefficientAve.Ave);
	with ReportForm do if Visible then
	    PAdjBox.Text := Format('%*.*f',[6,3,PriceAdjustCoefficientAve.Ave]);
	AddPoint(2,Periods,FirmAdjustCoefficientAve.Ave);
	with ReportForm do if Visible then
	    FAdjBox.Text := Format('%*.*f',[6,3,FirmAdjustCoefficientAve.Ave]);
    end;
    if ShowHistogram and (Periods mod CheckHistogramPeriod = 0) then
	Goods[1].DisplayHistogram;
    with ReportForm do if Visible then
	UnemploymentWageBox.Text := Format('%*.*f',[6,2,UnemploymentWage]);
end;

{
// Optimal Effort is calculated as follows.
// OptimalEmployees = KStar = 35.
// The Product from a unit of Effort = Sqrt(1+0.1*Capital)
// Output per worker = Effort*Sqrt(1+0.1*Capital)
// Firm output = KStar*Effort*Sqrt(1+0.1*Capital)
// Capital per firm is inialized to 10, but this assumes there are
//   10 firms per sector. Actually, there are about 15 firms per
//   sector, and workers/firm = 31 (about), so the optimal number of
//   firms per sector is approximately 15*(31/35) = 13. Thus optimal
//   capital per firm is about (initial firms/sector)*10/13 = 7.7,
//   since the price of capital must adjust so this is equal across
//   firms in the efficient allocation.
// However, since there are positive profits, actual prices are above
//   market-clearing profits, so optimally there should be more firms
//   than 13. If we calculate Aggregate Optimal Consumption for the
//   actual distribution of consumer utilities, we arrive at figures
//   that are approximately equal to actual sector supplies, so
//   a reasonable estimate of optimal firms per sector is 15.
// Assuming 15 firms per industry is optimal, we get
//   capital per firm = (initial firms/sector)*10/15 = 6.7, so
//   firm output = 35*Effort*Sqrt(1.67).
// If workers were homogeneous in the disutility of effort (actually,
    //   this varies from 0.0015 to 0.0025), optimal effort would maximize
    //   Effort*Sqrt(1.67) - (0.002)/(1-Effort).This gives POptimalEffort;
    }
    Procedure FindOptimalEffort;
begin
    OptimalEffort := 1-Sqrt(((AXMin+AXMax)/2)/Sqrt(1.67));
    with ReportForm do if Visible then
	OptimalEffortBox.Text := Format('%*.*f',[6,4,OptimalEffort]);
end;

Procedure TForm1.FirmsReproduce;
var
    J : Integer;
begin
    for J := 1 to NumGoods do begin
	Goods[J].GetNextFirmGeneration;
	if Debug then CheckAssignments;
    end;
end;

Procedure TForm1.AddAndDropFirms;
var
    J : Integer;
begin
    for J := 1 to NumGoods do begin
	if Goods[J].AddOneFirm then Goods[J].AddFirm(AFMakeCopy)
    else if Goods[J].DropOneFirm then Goods[J].DropAFirm;
end;
end;

Procedure TForm1.RunButtonClick(Sender: TObject);
label
ExitLbl;
var
    I,J : Integer;
begin
    AverageProfits := 0;
    AveProfDenom := 1;
    Periods := 0;
    if ShockBox.Checked then begin
	ShockPeriod := StrToInt(StartShockBox.Text);
	ShockDuration := StrToInt(ShockDurationBox.Text);
	LoadParamsBtnClick(Sender);
    end
    else ShockPeriod := 0;
    OldIntValue1 := 0;
    NumGoods := StrToInt(NumGoodsBox.Text);
    PCaption := IntToStr(NumGoods) + ' Goods';
    if (NumGoods mod 2 <> 0) then begin
	ShowMessage('Must have even number of sectors!');
	Exit;
    end;
    ReportForm.Visible := False;
    ReportForm.ShowForm := ReportBox.Checked;
    ShowGraphs := ShowSectorsBox.Value;
    if ShowGraphs < 1 then ShowGraphs := 1
else if ShowGraphs > NumGoods then ShowGraphs := NumGoods;
HGap := 20;
SetLength(Firms,NumGoods+1);
SetLength(Goods,NumGoods+1);
SetLength(AggOptConsumption,NumGoods+1);
NumWorkers := StrToInt(NumWorkersBox.Text)*NumGoods;
SetLength(Workers,NumWorkers+1);
TotalNumFirms := StrToInt(NumFirmsBox.Text)*NumGoods;
CapitalSupply := CapitalSupplyPerFirm*TotalNumFirms;
CalibratePeriod := StrToInt(CalibratePeriodBox.Text);
WorkerMutationRate := StrToFloat(WorkerMutationRateBox.Text);
ExtremeInitialize := ExtremeInitializationCk.Checked;
FirmMutationRate := StrToFloat(FirmMutationRateBox.Text);
MaxElSubst := StrToFloat(MaxElSubstBox.Text);
MinElSubst := StrToFloat(MinElSubstBox.Text);
MinPrice := StrToFloat(MinPriceBox.Text);
MaxPrice := StrToFloat(MaxPriceBox.Text);
TotalIncome:= 0;
UnemploymentWage := StrToFloat(UnemploymentWageBox.Text);
MaxWage := StrToFloat(MaximumWageBox.Text);
MinWage := StrToFloat(Form1.MinimumWageBox.Text);
DepreciationFactor := StrToFloat(DepreciationRateBox.Text);
Vision := StrToInt(VisionBox.Text);
EZVision := StrToInt(EZVisionBox.Text);
TotalPeriods := Round(StrToFloat(TotalPeriodsBox.Text));
CheckPeriod := StrToInt(CheckPeriodBox.Text);
DiddleAdjust := 0.995;
WorkerAdjustCoefficient := 0.995;
Debug := DebugBox.Checked;
if Assigned(AdjustGraph) then AdjustGraph.Destroy;
if ShowAdjustGraphBox.Checked then begin
    AdjustGraph := TXYGraph.Create(Form1);
    InitializeAdjustGraph;
end;
if Assigned(PriceGraph) then PriceGraph.Destroy;
if ShowPriceGraphBox.Checked then begin
    PriceGraph := TXYGraph.Create(Form1);
    InitializePriceGraph;
end;
if Assigned(EfficiencyGraph) then EfficiencyGraph.Destroy;
if ShowEfficiencyGraphBox.Checked then begin
    EfficiencyGraph := TXYGraph.Create(Form1);
    InitializeEfficiencyGraph;
end;
if Assigned(CapitalPriceGraph) then CapitalPriceGraph.Destroy;
if ShowCapitalPriceGraphBox.Checked then begin
    CapitalPriceGraph := TXYGraph.Create(Form1);
    InitializeCapitalPriceGraph;
end;
if Assigned(ProfitsGraph) then ProfitsGraph.Destroy;
if ShowProfitsGraphBox.Checked then begin
    ProfitsGraph := TXYGraph.Create(Form1);
    InitializeProfitsGraph;
end;
if Assigned(WealthGraph) then WealthGraph.Destroy;
if ShowWealthGraphBox.Checked then begin
    WealthGraph := TXYGraph.Create(Form1);
    InitializeWealthGraph;
end;
InitGetFirmStats;
PlaybackSpeedForm.Visible := False;
for I := 1 to LoadGraphLength do
    if Assigned(LoadGraph[I]) then begin
	LoadGraph[I].Destroy;
	LoadGraph[I] := Nil;
    end;
    MicroGraphLength := NumGoods;
    SetLength(MicroGraph,1+MicroGraphLength);
    MacroGraphLength := NumGoods;
    SetLength(MacroGraph,1+MacroGraphLength);
    for I := 1 to NumGoods do begin
	Goods[I] := Good.Init(I);
	with Goods[I] do begin
	    NumFirms := TotalNumFirms div NumGoods;
	    SetLength(Firms[I],NumFirms+1);
	    SupplyAve := TRAverage.Init(Vision);
	    DemandAve := TRAverage.Init(Vision);
	    PriceAve := TRAverage.Init(Vision);
	    EfficiencyAve:= TRAverage.Init(Vision);
	    CapitalAve := TRAverage.Init(Vision);
	    TargetEmploymentAve := TRAverage.Init(Vision);
	    NumFirmsAve := TRAverage.Init(Vision);
	    EmployeeAve := TRAverage.Init(Vision);
	    CEffortAve := TRAverage.Init(Vision);
	    ProfitAve := TRAverage.Init(Vision);
	    WageAve := TRAverage.Init(Vision);
	    EZAve := TRAverage.Init(Vision);
	    PriceAdjustCoefficientAve := TRAverage.Init(Vision);
	    FirmAdjustCoefficientAve := TRAverage.Init(Vision);
	    CapitalRentalPriceAve := TRAverage.Init(Vision);
	    EffortAve := TRAverage.Init(Vision);
	    if I <= ShowGraphs then begin
		//        MicroGraph[I].MakeVisible;
		//        MacroGraph[I].MakeVisible;
	    end;
	end;
    end;
    TotalEmployedAve := TRAverage.Init(EZVision);
    FoundEmploymentAve := TRAverage.Init(EZVision);
    LostEmploymentAve := TRAverage.Init(EZVision);
    FirmEstEZAve := TRAverage.Init(EZVision);
    MaxRho := StrToFloat(MaxDiscountRateBox.Text);
    MinRho := StrToFloat(MinDiscountRateBox.Text);
    AXMin := StrToFloat(MinCostOfEffortBox.Text);
    AXMax := StrToFloat(MaxCostOfEffortBox.Text);
    FindOptimalEffort;
    for I := 1 to NumGoods do with Goods[I] do
	for J := 1 to NumFirms do
	    Firms[I,J] := Firm.Init(False,Goods[I]);
	for I := 1 to NumWorkers do begin
	    Workers[I] := Worker.Init(I);
	    Workers[I].SetOptimalConsumption;
	    SetLength(Workers[I].Consumption,NumGoods+1);
	    for J := 1 to NumGoods do Workers[I].Consumption[J] := TRAverage.Init(Vision);
	    Workers[I].IncomeAve := TRAverage.Init(Vision);
	    Workers[I].AverageWage := TRAverage.Init(Vision);
	end;
	InitializeAssetDistribution;
	ShowHistogram := ShowFirmHistogramBox.Checked;
	if ShowHistogram then begin
	    if not Assigned(Hist) then Hist := TMyHistogram.Create(Self);
	    InitializeHistogram;
	end
	else if Assigned(Hist) then Hist.Close;
	InitializeEmployment;
	TextOutput.Clear;
	HaltSimulation := False;
	Running := True;
	InShock := False;
	for I := 1 to TotalPeriods do begin
	    Inc(Periods);
	    if LaborShockCk.Checked and (Periods = 1500) then LaborShock;
	    CurrentPeriod.Text := IntToStr(Periods);
	    Application.ProcessMessages;
	    if (ShockPeriod > 0) and (Periods mod ShockPeriod = 0) then CapitalShock;
	    if InShock then CheckShock;
	    if HaltSimulation then goto ExitLbl;
	    if Debug then CheckAssignments;
	    FoundEmployment := 0;
	    LostEmployment := 0;
	    AllocateCapital;
	    Produce;
	    Pay;
	    Sell;
	    if Debug then CheckAssignments;
	    FirmsReproduce;
	    GetFirmStats;
	    AddAndDropFirms;
	    GetWorkerStats;
	    NewFallbacks;
	    if Debug then CheckAssignments;
	    if Periods = CalibratePeriod then Calibrate;
	    if (Periods mod CheckPeriod = 0)  and (Periods>=CalibratePeriod) then begin
		DisplayResults;
		for J := 1 to NumGoods do Goods[J].AdjustEmployees;
		for J := 1 to NumGoods do Goods[J].AdjustEmployer;
	    end;
	    Mutate;
	    PriceAdjust;
	end;
	ExitLbl:
	    SaveReport;
	    Running := False;
	end;

procedure TForm1.HaltButtonClick(Sender: TObject);
begin
    HaltSimulation := True;
    Running := False;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    HaltSimulation := True;
    Application.Terminate;
end;

procedure TForm1.QuitButtonClick(Sender: TObject);
begin
    Close;
end;

procedure TForm1.HaltButtonMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
    HaltSimulation := True;
    Running := False;
end;

procedure TForm1.CheckDemandBtnClick(Sender: TObject);
begin
    AggregateDemandForm.CheckDemand;
end;

procedure TForm1.LoadPlotBtnClick(Sender: TObject);
begin
    ReportForm.Visible := False;
    HaltSimulation := False;
    LoadPlot;
end;

procedure TForm1.SavePlotBtnClick(Sender: TObject);
begin
    SavePlot;
end;

procedure TForm1.ShowSectorBtnClick(Sender: TObject);
begin
    with SectorBox do
	if (Value > 0) and (Value <= NumGoods) then begin
	    if Assigned(MicroGraph) and (MicroGraphLength >= Value) and
	    Assigned(MicroGraph[Value]) then begin
		with MicroGraph[Value] do begin
		    Left := 300;
		    Visible := True;
		end;
		with MacroGraph[Value] do begin
		    Left := 300;
		    Visible := True;
		end;
	    end
	    else if Assigned(LoadGraph) and (LoadGraphLength >= 2+NumGoods+Value) and
	    Assigned(LoadGraph[2+Value]) and
	    Assigned(LoadGraph[2+NumGoods+Value]) then begin
		with LoadGraph[2+Value] do begin
		    Left := 500;
		    Visible := True;
		end;
		with LoadGraph[2+NumGoods+Value] do begin
		    Left := 500;
		    Visible := True;
		end;
	    end;
	end;
    end;

procedure TForm1.SectorBoxChange(Sender: TObject);
begin
    PlaybackSpeedForm.SectorBox.Value := SectorBox.Value;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    Running := False;
end;

procedure TForm1.ReportBoxClick(Sender: TObject);
begin
    with ReportBox do begin
	ReportForm.ShowForm := Checked;
	ReportForm.Visible := Checked;
    end;
    FindOptimalEffort;
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
    SavePlotBtnClick(Self);
end;

procedure TForm1.Halt1Click(Sender: TObject);
begin
    HaltButtonClick(Self);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
    Close;
end;

procedure TForm1.Load1Click(Sender: TObject);
begin
    LoadPlotBtnClick(Self);
end;

procedure TForm1.Run1Click(Sender: TObject);
begin
    RunButtonClick(Self);
end;

procedure TForm1.CheckDemand1Click(Sender: TObject);
begin
    CheckDemandBtnClick(Self);
end;

procedure TForm1.CreateNewScript1Click(Sender: TObject);
begin
    with ScriptForm do begin
	Caption := 'Create Script';
	ShowModal;
    end;
end;

procedure TForm1.EditScript1Click(Sender: TObject);
begin
    ScriptForm.EditScript;
end;

procedure TForm1.RunScript1Click(Sender: TObject);
var
    I,J,NumExecutions : Integer;
    S : String;
begin
    NumExecutions := 0;
    with ScriptForm,Memo1 do begin
	if not GetScript then Exit;
	for I := 0 to Lines.Count-1 do begin
	    S := Lines[I];
	    if (S='') or (S[1] = ' ') then Continue;
	    if Pos('Total Periods:',S) > 0 then begin
		Delete(S,1,Pos(':',S));
		while (S <> '') and (S[1] = ' ') do Delete(S,1,1);
		TotalPeriodsBox.Text := S;
	    end
	    else if Pos('Number of Sectors:',S) > 0 then begin
		Delete(S,1,Pos(':',S));
		while (S <> '') and (S[1] = ' ') do Delete(S,1,1);
		NumGoodsBox.Text := S;
	    end
	    else if Pos('Number of Executions:',S) > 0 then begin
		Delete(S,1,Pos(':',S));
		while (S <> '') and (S[1] = ' ') do Delete(S,1,1);
		NumExecutions := StrToInt(S);
		Form1.NumExecutionsBox.Text := S;
		Form1.NumExecutionsBox.Enabled := True;
	    end;
	end;
	Form1.CurrExecutionBox.Enabled := True;
	ExPlotPar.Clear;
	ExPlotTxt.Clear;
	for I := 1 to NumExecutions do begin
	    Form1.CurrExecutionBox.Text := IntToStr(I);
	    Form1.RunButtonClick(Self);
	    if HaltSimulation then Exit;
	    CreatePlot;
	    for J := 0 to PlotTxt.Count-1 do
		ExPlotTxt.Append(PlotTxt.Strings[J]);
	end;
    end;
    ExPlotTxt.SaveToFile('Trial.Txt');
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
    with SpinEdit1,PlaybackSpeedForm.TrackBar1 do begin
	if Value < Min then Value := Min
    else if Value > Max then Value := Max;
    Position := Value;
end;
end;

procedure TForm1.LoadParamsBtnClick(Sender: TObject);
begin
    LoadParameters;
end;

procedure TForm1.SaveParamsBtnClick(Sender: TObject);
begin
    SaveParameters;
end;

procedure TForm1.LoadParameters1Click(Sender: TObject);
begin
    LoadParamsBtnClick(Sender);
end;

procedure TForm1.SaveParameters1Click(Sender: TObject);
begin
    SaveParamsBtnClick(Sender);
end;

initialization
//  Randomize;
RandSeed := 123456;
TextOutput := TStringList.Create;
with TextOutput do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
PlotInput := TStringList.Create;
with PlotInput do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
PlotPar := TStringList.Create;
with PlotPar do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
PlotTxt := TStringList.Create;
with PlotTxt do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
PlotRpt := TStringList.Create;
with PlotRpt do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
ExPlotPar := TStringList.Create;
with ExPlotPar do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
ExPlotTxt := TStringList.Create;
with ExPlotTxt do begin
    Duplicates := dupIgnore;
    Sorted := False;
end;
Hist := Nil;
PriceGraph := Nil;
end.
