USE [Pantheon_MF_3620]
GO
/****** Object:  StoredProcedure [dbo].[pHE_MoveCreAll]    Script Date: 19. 01. 2025 13:08:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[pHE_MoveCreAll]
   @cDocType     varchar(4),
   @cIssuer      varchar(30),
   @cReceiver    varchar(30),
   @dDate        DateTime,
   @nUserId      Integer,
   @cDept        varchar(30),
   @cKey         varchar(13) output,
   @cCheckAuthor char(1) = 'F',
   @cStatus      Varchar(2) = 'T' output,
   @cError       Varchar(1024) = '' output,
   @p_cDoc1      Varchar(35) = '',
   @p_dDateDoc1  DateTime = null,
   @p_cDoc2      Varchar(35) = '',
   @p_dDateDoc2  DateTime = null,
	@p_cInsertedFrom  char(1) = 'S' ,
	@p_nQId       integer = null output,
	@p_dDateVAT   datetime = null

as
set nocount on

declare
   @cpUserName          varchar(255),
   @cpLocalization      varchar(2),
   @cpDocType			varchar(4),
   @cKeyView			varchar(15),
   @nClerk				int,
   @cDeptOut			varchar(30),
   @cCostDrvOut			varchar(16),
   @cForm    			varchar(3),
   @cPrsn3				varchar(30),
   @cNote				varchar(4000),
   @cNote2				varchar(4000),
   @cNote3				varchar(4000),
   @dDateInv			datetime,
   @dDateVAT			datetime,
   @dDateDue			datetime,
   @cCurrency			varchar(3),
   @nNoteClerk			int,
   @nFxRate				decimal(12,6),
   @nBnkAcctNo			int,
   @nDaysForPayment		int,
   @cPriceRate			char(1),
   @cWayOfSale			char(1),
   @cPosted				char(1),
   @cTriangTrans		char(1),
   @cVATAttType			varchar(2),
   @cAcctClaimLiab		varchar(13),
   @cRoundVATOnDoc		char(1),
   @nRoundPrice     decimal(9,4),
   @nRoundValue     decimal(9,4),
   @nRoundValueOC   decimal(9,4),
   @nRoundItem      decimal(9,4),
   @nRoundItemFC    decimal(9,4),
   @cReceiverStock		char(1),
   @cIssuerStock		char(1),
   @cVerifiedPrices		char(1),
   @cRefNo3				varchar(35),
   @cRefNo4				varchar(35),
   @cIsoCountry			varchar(3),
   @cStatement			varchar(400),
   @cPayMethod			varchar(3),
   @cDelivery			varchar(2),
   @cParity				varchar(3),
   @cParityPost			CHAR(13),
   @cDoc1				varchar(35),
   @dDateDoc1			datetime,
   @cDoc2				varchar(35),
   @dDateDoc2			datetime,
   @cRefNo1				varchar(35),
   @cRefNo2				varchar(35),
   @cDutyTran			char(1),
   @cCode1				varchar(2),
   @cCode2				varchar(2),
   @cCode3				varchar(2),
   @cInvoiceForm		varchar(3),
   @cDocTypePayOrd		varchar(4),
   @nValue				decimal(19,4),
   @nVAT				decimal(19,4),
   @nRebate				decimal(19,4),
   @nExcise				decimal(19,4),
   @nDiscount			decimal(19,4),
   @nCalcSum			decimal(19,4),
   @nCalcDiscPrc		decimal(19,4),
   @nForPay				decimal(19,4),
   @nCurrValue			decimal(19,4),
   @nTransport			decimal(19,4),
   @nDuty    			decimal(19,4),
   @nDirectCost			decimal(19,4),
   @nIncTax 			decimal(19,4),
   @nVatIn	 			decimal(19,4),
   @nVatBase 			decimal(19,4),
   @cCreatFromWO		char(1),
   @dDateBeforeVAT		DateTime,
   @dVATAttDate			DateTime,
   @dDateDDVPay			datetime,
   @cTransPaperForm		varchar(3),
   @cCreatePayOrd		char(1),
   @cDocTypePayOrdFgn	varchar(4),
   @cLimitDuty       	varchar(8),
   @cPayPurpose1        varchar(25),
   @cPayPurpose2        varchar(25),
   @cPayPurpose3        varchar(25),
   @nOurBankAcctNo		Int,
   @nOurBankAcctNoFgn   Int,
   @cContactPrsn        varchar(30),
   @cContactPrsn3       varchar(30),
   @nBankAcctNo         Int,
   @cContractNo         Varchar(30),
   @cIDBCState          varchar(2),
   @cPackNum            varchar(30),
   @cInternalNote       Varchar(2000),
   @nFgnBankNo          Int,
   @cpIsPrsn3           char(1),
   @cdSetOf             char(1),
   @cdType              char(1),
   @cdTypeOfDoc         char(1),
   @cdIsBuyerRMA        char(1),
   @cdIsSupplRMA        char(1),
   @cpSubject           varchar(30),
   @cpIssuer            varchar(30),
   @cpReceiver          varchar(30),
   @cpFillType          char(1),
   @cpDept              varchar(30),
   @dpDate              DateTime,
   @ciBuyerLimitCtrl    char(1),
   @niLimit             Float,
   @cpIsVAT             char(1),
   @cpIsInsertItem      char(1),
   @cAvtor              Varchar(50),
   @cpSetDateVAT        char(1),
   @cpSale              char(1),
   @cpCheckWayOfSale    char(1),
   @cpOL                char(1),
   @v_cError              Varchar(1024),
   @v_cStatus             Varchar(2),
   @cPayer              varchar(30),
   @cFiskPrintNo        Varchar(20),
   @cFiskPrintNoS       Varchar(20),
  @cFieldSA             varchar(255),
  @cFieldSB             varchar(255),
  @cFieldSC             varchar(255),
  @cFieldSD             varchar(255),
  @cFieldSE             varchar(255),
  @cFieldSF             varchar(255),
  @cFieldSG             varchar(255),
  @cFieldSH             varchar(255),
  @cFieldSI             varchar(255),
  @cFieldSJ             varchar(255),
  @nFieldNA             decimal(19,6),
  @nFieldNB             decimal(19,6),
  @nFieldNC             decimal(19,6),
  @nFieldND             decimal(19,6),
  @nFieldNE             decimal(19,6),
  @nFieldNF             decimal(19,6),
  @nFieldNG             decimal(19,6),
  @nFieldNH             decimal(19,6),
  @nFieldNI             decimal(19,6),
  @nFieldNJ             decimal(19,6),
  @dFieldDA             datetime,
  @dFieldDB             datetime,
  @dFieldDC             datetime,
  @dFieldDD             datetime,

  @cTransportCalcType  char(1),
  @cUPNReference        Varchar(2),
  @cUPNCode             Varchar(4),
  @cUPNControlNum       Varchar(2),
  @cProc                varchar(2),
  @cParityType char(1),
  @cDeliveryUnderART163A varchar(2),
  @nReversechargeCoefficient float,
  @cTransporter               varchar(30),
  @cVehicleRegistrationNumber varchar(30),
  @cTrailerRegistrationNumber varchar(30),
  @cRetailSale char(1),
	@v_cDocStatus char(1)


set @v_cStatus           = 'T'
set @v_cError            =  ''
set @cpUserName		   = ''
set @cpIsVAT		   = 'T'
set @cpIsInsertItem    = 'T'
set @cpSetDateVAT      = 'F'
set @cpCheckWayOfSale  = 'F'
set @cpSale            = 'F'
set @cpOL			   = 'F'


set @nValue            = 0
set @nCurrValue        = 0
set @nRebate           = 0
set @nTransport        = 0
set @nDuty             = 0
set @nDirectCost       = 0
set @nIncTax           = 0
set @nVAT              = 0
set @nVatIn            = 0
set @nVatBase          = 0
set @nDiscount         = 0
set @nForPay           = 0
set @cContactPrsn      = ''
set @cDoc1             = ''
set @cDoc2             = ''
set @cLimitDuty		   = ''
set @cCode1            = ''
set @cCode2			   = ''
set @cCode3			   = ''
set @cPayPurpose1      = ''
set @cPayPurpose2      = ''
set @cPayPurpose3      = ''
set @cRefNo1           = ''
set @cRefNo2           = ''
set @cContactPrsn3     = ''
set @cTransPaperForm   = ''
set @cCreatePayOrd     = ''
set @cCostDrvOut       = ''
set @cContractNo       = ''
set @cIdbcState        = ''
set @cRefNo3           = ''
set @cRefNo4           = ''
set @cInternalNote     = ''
set @cForm             = ''
set @cInvoiceForm      = ''
set @cDutyTran         = ''
set @cCreatFromWO      = ''
set @cPackNum          = ''
set @cDocTypePayOrd    = ''
set @cDocTypePayOrdFgn = ''
set @cStatement        = ''
set @cPayMethod        = ''
set @cDelivery         = ''
set @cParity           = ''
set @cParityPost       = ''
set @cParityType       = ''
set @nOurBankAcctNo    = 0
set @nOurBankAcctNoFgn = 0
set @nFgnBankNo        = 0
set @cFiskPrintNo      = ''
set @cFiskPrintNoS     = ''
set @cUPNReference     = 'SI'
set @cUPNCode          = ''
set @cUPNControlNum    = ''
set @cProc             = ''
set	@cRetailSale       = 'F'



	select top 1 @cpLocalization = acLocalization
		from tPA_SysParamSys

	select top 1 @cdSetOf = acSetOf,
					 @cdType  = acType,
					 @cdTypeOfDoc  = acTypeOfDoc,
					 @cdIsBuyerRMA = acIsBuyerRMA,
					 @cdIsSupplRMA = acIsSupplRMA
		from tPA_SetDocType
		where acDocType = @cDocType

	if @cdSetOf = 'F' and @cdType = 'P' and @cdIsBuyerRMA = 'T'
	begin
		set @cAvtor = 'ServisPreKup'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'P' and @cdIsSupplRMA = 'T'
	begin
		set @cAvtor = 'ServisPreDob'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'I' and @cdIsBuyerRMA = 'T'
	begin
		set @cAvtor = 'ServisIzdKup'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'T'
	end
	else if @cdSetOf = 'F' and @cdType = 'I' and @cdIsSupplRMA = 'T'
	begin
		set @cAvtor = 'ServisIzdDob'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'I'
	begin
		set @cAvtor = 'PrometIzd'
		set @cpSetDateVAT = 'F'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'T'
	end
	else if @cdSetOf = 'F' and @cdType = 'M'
		set @cAvtor = 'PrometIzd'
	else if @cdSetOf = 'F' and @cdType = 'P'
	begin
		set @cAvtor = 'PrometPre'
		set @cpSetDateVAT = 'F'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'N'
	begin
		set @cAvtor = 'PrometInventura'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'C'
	begin
		set @cAvtor = 'PrometSprCene'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'F' and @cdType = 'E'
	begin
		set @cAvtor = 'PrometPrenos'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'C' and @cdType = 'P'
	begin
		set @cAvtor = 'PrometCarinaPre'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'C' and @cdType = 'I' and @cdTypeOfDoc = 'M'
	begin
		set @cAvtor = 'PrometCarinaIzd'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'C' and @cdType = 'I' and @cdTypeOfDoc = 'Z'
	begin
		set @cAvtor = 'PrometCarinaKV'
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'F'
		set @cpSale = 'F'
	end

	if @cdSetOf = 'F' and @cdType = 'I' and @cdTypeOfDoc = 'A'
	begin
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'T'
	end
	else if @cdSetOf = 'F' and @cdType = 'P' and @cdTypeOfDoc = 'A'
	begin
		set @cpSetDateVAT = 'T'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'F'
	end
	else if @cdSetOf = 'Q' and @cdType = 'I'
	begin
		set @cAvtor = 'PrometTrosSkladIzd'
		set @cpSetDateVAT = 'F'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'T'
	end
	else if @cdSetOf = 'Q' and @cdType = 'P'
	begin
		set @cAvtor = 'PrometTrosSkladPre'
		set @cpSetDateVAT = 'F'
		set @cpCheckWayOfSale = 'T'
		set @cpSale = 'F'
	end

	if @cpLocalization = 'KO'
	  select @nReversechargeCoefficient = anReversechargeCoefficient from tPA_SysParam
	else 
	  set @nReversechargeCoefficient = 100  

	exec pHE_MoveNewPoz @cDocType,
						@nUserID,
						@cpUserName,
						@cpLocalization,
						@cpDocType output,
						@cKey output,
						@cKeyView output,
						@nClerk output,
						@cpDept output,
						@cDeptOut output,
						@cpIssuer output,
						@cpReceiver output,
						@cPrsn3 output,
						@cNote output,
						@dpDate output,
						@dDateInv output,
						@dDateVAT output,
						@dDateDue output,
						@cCurrency output,
						@nNoteClerk output,
						@nFxRate output,
						@nBnkAcctNo output,
						@nDaysForPayment output,
						@cPriceRate output,
						@cWayOfSale output,
						@cPosted output,
						@cTriangTrans output,
						@cVATAttType output,
						@cAcctClaimLiab output,
						@cRoundVATOnDoc output,
						@nRoundValue output,
						@nRoundItem output,
						@cReceiverStock output,
						@cIssuerStock output,
						@cVerifiedPrices output,
						@cRefNo3 output,
						@cRefNo4 output,
						@cIsoCountry output,
						@cStatement output,
						@cPayMethod output,
						@cDelivery output,
						@cParity output,
						@cParityPost output,
						@cParityType output,
						@cDoc1 output,
						@dDateDoc1 output,
						@cDoc2 output,
						@dDateDoc2 output,
						@cRefNo1 output,
						@cRefNo2 output,
						@cDutyTran output,
						@cCode1 output,
						@cCode2 output,
						@cCode3 output,
						@cInvoiceForm output,
						@cDocTypePayOrd output,
						@nValue output,
						@nVAT output,
						@nExcise output,
						@nDiscount output,
						@nCalcSum output,
						@nCalcDiscPrc output,
						@nForPay output,
						@nCurrValue output,
						@cCreatePayOrd output,
						@cDocTypePayOrdFgn output,
						@nOurBankAcctNo output,
						@cTransportCalcType output,
						@v_cError output,
						@v_cStatus output,
						@nRoundItemFC output,
							  @nRoundValueOC output,
							  @nRoundPrice output,
						@nReversechargeCoefficient output,
						default,
						@nOurBankAcctNoFgn output,
							  @cCostDrvOut output

	set @cpIsPrsn3 = 'F'

	set @dpDate   = @dDate
	IF @p_dDateVAT is not null
		set @dDateVAT = @p_dDateVAT
	else
		set @dDateVAT = @dDate
	set @dDateInv = @dDate
	set @dDateDue = @dDate

	if @cDept <> '' and @cDept is not null
	  set @cpDept   = @cDept

	if ((@cdType = 'I') or (@cdType = 'M') or (@cdType = 'E') or (@cdType = 'N') or (@cdType = 'C'))
	begin
	  set @cpSubject  = @cReceiver
	  set @cpReceiver = @cReceiver
	  set @cpFillType = 'I'
	  set @cPrsn3 = @cReceiver
	end

	if (@cdType = 'P') and (@cIssuer <> '' and @cIssuer is not null)
	begin
	  set @cpSubject  = @cIssuer
	  set @cpIssuer   = @cIssuer
	  set @cpFillType = 'P'
	  set @cPrsn3     = @cIssuer
	end

	if (@cdSetOf = 'F') and (@cdType = 'N')
	  set @cpReceiver = @cReceiver

	if (@cdSetOf = 'F') and (@cdType = 'I') and (@cdIsSupplRMA = 'T' and @cdIsBuyerRMA = 'F')
	begin
	  set @cpFillType = 'P'
	end

	if (@cdSetOf = 'F') and (@cdType = 'P') and (@cdIsSupplRMA = 'F' and @cdIsBuyerRMA = 'T')
	begin
	  set @cpFillType = 'I'
	end

	IF (@cdSetOf = 'F') and (@cdType = 'P')
		select @cPayer = acPayerS
			from tHE_SetSubj
			where acSubject = @cPrsn3
	ELSE
		select @cPayer = acPayer
			from tHE_SetSubj
			where acSubject = @cPrsn3

	if (@cPayer <> '') and (@cPayer <> @cPrsn3) begin
		set @cpIsPrsn3 = 'T'
		set @cpSubject = @cPayer
		if @cdType = 'P'
		begin
			set @cpIssuer = @cPayer
		end
		else
			set @cpReceiver  = @cPayer
	end

	if @v_cStatus = 'T'
	begin
	  select @ciBuyerLimitCtrl = acBuyerLimitCtrl,
				@niLimit          = anLimit
		 from tHE_SetSubj
		where acSubject = @cpSubject

	  exec pHE_MoveSubjectCh	@cpIsPrsn3,
								@cKey,
								@cDocType,
								@cpSubject,
								@cpFillType,
								@cDocTypePayOrd,
								@cpUserName,
								@dpDate,
								@dDateDoc2,
								@dDateInv,
								@dDateVAT,
								@cpLocalization,
								@nUserId,
								@ciBuyerLimitCtrl,
								@niLimit,
								@cWayOfSale,
								@cpIsVAT,
								@cPrsn3 output,
								@cpIssuer output,
								@cpReceiver output,
								@cContactPrsn output,
								@cContactPrsn3 output,
								@cPriceRate output,
								@nBnkAcctNo output,
								@cIsoCountry output,
								@nClerk output,
								@cpDept output,
								@cStatement output,
								@cWayOfSale output,
								@cPayMethod output,
								@cDelivery output,
								@cCurrency output,
								@nDaysForPayment output,
								@cParity output,
								@cParityPost output,
								@cParityType output,
								 @cDoc1 output,
								 @dDateDoc1 output,
								 @cDoc2 output,
								 @cRefNo1 output,
								 @cRefNo2 output,
								 @nFXRate output,
								 @cDutyTran output,
								 @cCode3 output,
								 @cInvoiceForm output,
								 @nRoundItem output,
								 @nRoundValue output,
								 @nValue output,
								 @nVAT output,
								 @nExcise output,
								 @nDiscount output,
								 @nCalcSum output,
								 @nCalcDiscPrc output,
								 @nForPay output,
								 @nCurrValue output,
								 @dDateDue output,
								 @nBankAcctNo output,
								 @v_cError output,
								 @v_cStatus output,
										 @cVerifiedPrices
	end


	if @cReceiver <> '' and @cReceiver is not null
	begin
	  if ((@cdType = 'I') or (@cdType = 'M') or (@cdType = 'E')) and (@cpIsPrsn3 = 'F')
		 set @cpReceiver = @cReceiver
	  if (@cdType = 'P')
		 set @cpReceiver = @cReceiver
	end
	if @cIssuer <> '' and @cIssuer is not null
	begin
	  if ((@cdType = 'I') or (@cdType = 'M') or (@cdType = 'E'))
		 set @cpIssuer   = @cIssuer
	  if (@cdType = 'P') and (@cpIsPrsn3 = 'F')
		 set @cpIssuer   = @cIssuer
	end

	if (@cdSetOf = 'F') and (@cdType = 'I') and  (@cdIsSupplRMA = 'F' and @cdIsBuyerRMA = 'F') and (@cpIsPrsn3 = 'T')
	begin
	  select top 1 @cContactPrsn = Cast(LTrim(RTrim(acPrefix) + ' ' + LTrim(RTrim(acName) + ' ' + LTrim(RTrim(acMiddle) + ' ' + RTrim(acSurname)))) as varchar(255))
											  from tHE_SetSubjContact
											  where acSubject = @cpReceiver and acActive = 'T'
											  order by anNo
	end

	if (@cContactPrsn is null)
	  set @cContactPrsn = ''
	if (@cContactPrsn3 is null)
	  set @cContactPrsn3 = ''

	if @v_cStatus = 'T'
	begin
	  if @p_cDoc1 <> ''
			set @cDoc1 = @p_cDoc1
	  if @p_cDoc2 <> ''
			set @cDoc2 = @p_cDoc2
	  if not @p_dDateDoc1 is null
			set @dDateDoc1 = @p_dDateDoc1
	  if not @p_dDateDoc2 is null
			set @dDateDoc2 = @p_dDateDoc2

		set @v_cDocStatus = null
	  set @v_cDocStatus = (Select TOP 1 acStatus from tPA_SetDoctypeStat where acDocType = @cDocType and acVerified = 'F')
		if @v_cDocStatus is null
		  set @v_cDocStatus = (Select TOP 1 acStatus from tPA_SetDoctypeStat where acDocType = @cDocType and acVerified = 'T')
	  if @v_cDocStatus is null
		begin
		  Insert into [dbo].[tPA_SetDocTypeStat] (acDocType, acStatus, acVerified)
			Select SDT.acDoctype, 'N', 'F'
			FROM [dbo].[tPA_SetDocType] SDT
			OUTER APPLY
			(
			 Select TOP 1 acStatus from [dbo].[tPA_SetDocTypeStat]  where acDocType = SDT.acDocType
			) SDTS
			where SDT.acDocType = @cDocType and SDTS.acStatus is null

		  set @v_cDocStatus = ''  
	  end
		IF NOT EXISTS (SELECT TOP 1 acSubject FROM tHE_SetSubj WHERE acSubject = @cReceiver)
		BEGIN
			SET @v_cStatus = 'F'
			SELECT @v_cError = acValue FROM dbo.fPA_ReplaceFirst_ITF((SELECT acDescr FROM dbo.fPA_GetIrisMsg_ITF(5681, 17)), '%s', RTRIM(@cReceiver))
		END
		IF NOT EXISTS (SELECT TOP 1 acSubject FROM tHE_SetSubj WHERE acSubject = @cIssuer)
		BEGIN
			SET @v_cStatus = 'F'
			SELECT @v_cError = acValue FROM dbo.fPA_ReplaceFirst_ITF((SELECT acDescr FROM dbo.fPA_GetIrisMsg_ITF(5681, 16)), '%s', RTRIM(@cIssuer))
		END

	IF @v_cStatus = 'T'
	BEGIN
	  exec pHE_MoveUpdate @cpIsInsertItem,
						  @cAvtor,
						  @cCheckAuthor,
						  @nUserId,
						  @cDocType,
						  @cpSetDateVAT,
						  @cpSale,
						  @cpCheckWayOfSale,
						  @cpOL,
						  @ciBuyerLimitCtrl,
						  @niLimit,
						  0,
						  @cpLocalization,
						  'F',
						  @cReceiver,
						  @cIssuer,
						  @cKey output,
						  @cKeyView output,
						  @cWayOfSale output,
						  @cCurrency output,
						  @nFXRate output,
						  @dpDate output,
						  @dDateVAT output,
						  @dDateInv output,
						  @cVerifiedPrices output,
						  @cpIssuer output,
						  @cIssuerStock output,
						  @cpReceiver output,
						  @cReceiverStock output,
						  @cPrsn3 output,
						  @cContactPrsn output,
						  @cpDept output,
						  @cDeptOut output,
						  @cCostDrvOut output,
						  @cDoc1 output,
						  @dDateDoc1 output,
						  @cDoc2 output,
						  @dDateDoc2 output,
						  @cStatement output,
						  @cPriceRate output,
						  @cPayMethod output,
						  @cDelivery output,
						  @cForm output,
						  @cInvoiceForm output,
						  @nDaysForPayment output,
						  @dDateDue output,
						  @nRoundItem output,
						  @nRoundValue output,
						  @nValue output,
						  @nVAT output,
						  @nDiscount output,
						  @nForPay output,
						  @nCurrValue output,
						  @nRebate output,
						  @cLimitDuty output,
						  @nClerk output,
						  @cCode1 output,
						  @cCode2 output,
						  @cCode3 output,
						  @cPayPurpose1 output,
						  @cPayPurpose2 output,
						  @cPayPurpose3 output,
						  @cRefNo1 output,
						  @cRefNo2 output,
						  @cContactPrsn3 output,
						  @nTransport output,
						  @nDuty output,
						  @nDirectCost output,
						  @nIncTax output,
						  @cPosted output,
						  @cTransPaperForm output,
						  @nVATIn output,
						  @cParity output,
						  @cParityPost output,
						  @cParityType output,
						  @cDutyTran output,
						  @nVATBase output,
						  @nBnkAcctNo output,
						  @cCreatFromWO output,
						  @dDateBeforeVAT output,
						  @cISOCountry output,
						  @cTriangTrans output,
						  @cAcctClaimLiab output,
						  @cVATAttType output,
						  @dVATAttDate output,
						  @cCreatePayOrd output,
						  @nNoteClerk output,
						  @dDateDDVPay output,
						  @cNote,
						  @cNote2,
						  @cNote3,
						  @cContractNo output,
						  @cIDBCState output,
						  @cRoundVATOnDoc output,
						  @cRefNo3 output,
						  @cRefNo4 output,
						  @cPackNum output,
						  @cDocTypePayOrd output,
						  @cDocTypePayOrdFgn output,
						  @nOurBankAcctNo output,
						  @cInternalNote output,
					@nFgnBankNo output,
					@v_cDocStatus,
					0,
					null,
					0,
					null,
					0,
					null,
					@cFieldSA output,
					@cFieldSB output,
					@cFieldSC output,
					@cFieldSD output,
					@cFieldSE output,
					@cFieldSF output,
					@cFieldSG output,
					@cFieldSH output,
					@cFieldSI output,
					@cFieldSJ output,
					@nFieldNA output,
					@nFieldNB output,
					@nFieldNC output,
					@nFieldND output,
					@nFieldNE output,
					@nFieldNF output,
					@nFieldNG output,
					@nFieldNH output,
					@nFieldNI output,
					@nFieldNJ output,
					@dFieldDA output,
					@dFieldDB output,
					@dFieldDC output,
					@dFieldDD output,
					@cFiskPrintNo,
					@cFiskPrintNoS,
					@cTransportCalcType output,
					@v_cError output,
					@v_cStatus output,
					@cUPNReference output,
					@cUPNCode output,
					@cUPNControlNum output,
					@cProc output,
					@nRoundItemFC output,
					@cDeliveryUnderART163A  output,
					@nRoundValueOC output,
					@nRoundPrice output,
				default,
				default,
				default,
				default,
				default,
				default,
				default,
				default,
				default,
				default,
				default,
				@nReversechargeCoefficient,
				@cTransporter                output,
				  @cVehicleRegistrationNumber  output,
					@cTrailerRegistrationNumber  output,
				  default,
				  default,
					default,
					@nOurBankAcctNoFgn output,
							'',
							@p_cInsertedFrom,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					default,
					@p_nQId output


	END
END
set @cStatus = @v_cStatus
set @cError  = @v_cError

if @v_cStatus <> 'T'
  set @cKey = null