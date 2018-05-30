function varargout = fSolvReg_PI(Eq1,Eq2, X0Beg, Descr, g, Input, options)
% ������������ ������� ������� ��������� ��� ������ ��������� �� 1-�� �
% 2-�� ������ ��������. ������������ ����� ������ ������� � ����������� ��
% ���������� ��� ������������ ���������, � ����� ������������ ����������
% ��������� �� 2-�� ������ ��������, � ������ ���� ����� ������ � �����
% �������� ������� ���������. ������� ���������� �� fDriveRegim. �������
% ���������� fCalcEq2, fResLim, fCalcU_PI, fTolCon_UU.
%
% varargout = fSolvReg_PI(Eq1,Eq2, X0Beg, Descr, g, Input, options)

% varargout - cell-������ �������� ������ ������������ �� 5 �� 7;
% varargout{1} - ������ ����������� �������� ����� ������;
% varargout{2} - ��������� �������� ������� � ��� ����������;
% varargout{2}.mod - ������ ���������� � ����;
% varargout{2}.d - ���� ���������� � ����;
% varargout{3} - ������ ��������� ���������� �������� �� ����������� �������;
% varargout{4} - ��� ���� �� ����������� �������;
% varargout{5} - ���� ������� ���������� ������� ������;
% varargout{6} - ������� ���������� ��������;
% varargout{7} - ������ ���������� �� ������� ��������� � �����;
% Eq1 - ��������� ��������� �� 1-�� ������ ��������, ���������� �� fEq1_PI;
% Eq2 - ��������� ��������� �� 2-�� ������ ��������, ���������� �� fEq2_PI;
% X0Beg - ������ ��������� �����������;
% Descr - ������ ���������� ��������� ����������� ����������;
% g - ���� ��������� �������� � ���� ������� CGraph;
% Input - ��������� ������ �� ���� ������ �� ������� fInputCalcReg_PI;
% options - ������ ����� ������� ������;
% options.TolFun - �������� �������;
% options.CountIter - ������������ ���������� ��������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

% �������� ���������� �������� ������
if nargout<4||nargout>7
    error('�������� ���������� �������� ����������');
end
if nargin<6||nargin>7
    error('�������� ���������� ������� ����������');
end
if nargin==6
    options.TolFun=10^-2;
    options.MaxIter=20;
end
% ������� ����� ��� ������� ������� ��������� �� 2-�� ������ �������� ��
% ������ ����������-���������
optionsLM=optimoptions(@fsolve,'Algorithm','levenberg-marquardt',...
    'InitDamping',10^(-2),'TolFun',10^(-5),'TolX',10^(-5), 'Display','off',...
    'FinDiffType', 'central','FunValCheck','on','Jacobian','on');
ParamIterLim=1; % ��������, ���������� ���������� �������� ������� �������� ����� ��� ���������� �������� ����������� ���������� ������
ParamLimAl=8; % ��������, ���������� ���������� �������� �� ������ ������������ �������� ����� �����
ParamNotCheckLim=2; % ��������, ���������� ���������� �������� � ����������� ������ ����� ����� �������� ���������� ������� �������� �����
ParamStartLim=1; % ���������� �������� ������� ������, ���������� �� ��������� ���������� �������� ��������
% ������������� ����������
Nn=g.nod.n;
Nb=g.rib.n;
nEq2= length(X0Beg);
% ����������� ��������
nKont=nEq2/2;
optionsU.TolFun=options.TolFun;
UmodCur=Input.Umod;
dUCur=Input.dU;
Qmin=Input.Qmin(1:g.nod.n);
Qmax=Input.Qmax(1:g.nod.n);
NodeTypeCur=Input.TypeN(1:g.nod.n);
NbVal(g.nod.n)=0;
nBU=0;
nPU=0;
I1(g.rib.n,1)=0;
I2(g.rib.n,1)=0;
Qg(g.nod.n,1)=0;
dU(g.nod.n,1)=0;
Su.P(g.nod.n,1)=0;
Su.Q(g.nod.n,1)=0;
Qn(g.nod.n,1)=0;
Ibu.I1(g.nod.n)=0;
Ibu.I2(g.nod.n)=0;
% ����������� �������� � �����
% ��������
Su.P(1:g.nod.n)=Input.Pn(1:g.nod.n)-Input.Pg(1:g.nod.n);
% ����������
% ��� ����������� � ������������� �����
Su.Q(NodeTypeCur(1:g.nod.n)~=nTip.PU)=Input.Qn(NodeTypeCur(1:g.nod.n)~=nTip.PU)...
    -Input.Qg(NodeTypeCur(1:g.nod.n)~=nTip.PU);
% ��� ������������ �����
Su.Q(NodeTypeCur(1:g.nod.n)==nTip.PU)=Input.Qn(NodeTypeCur(1:g.nod.n)==nTip.PU);
% ������������� �������� ��� ����������� �������� ���������� ��������
% �������� � ���������
Qn(1:g.nod.n)=Input.Qn(1:g.nod.n);
Qg(1:g.nod.n)=Input.Qg(1:g.nod.n);
IuR(1:g.nod.n)=0;
IuI(1:g.nod.n)=0;
nPU=0;
nBU=0;
BU=[];
PU=[];
noPU=0;
% �������� ������� ������������� � PU �����
for J=1:g.nod.n
    switch NodeTypeCur(J)
        % ������������� ����
        case nTip.BU
            nBU=nBU+1;
            BU(nBU)=J;
            if nBU==1
                NopG=J;
            end
            % ������������ ����
        case nTip.PU
            nPU=nPU+1;
            PU(nPU)=J;
        otherwise
    end
end
PUMod=false;
% ������������� ������� ��������� ��������� ����� �����
if nPU>0
    PUMod(nPU)=false;
end
% ������������� ���������� �������� ����
Uop.mod=double(UmodCur(NopG));
Uop.d=double(dUCur(NopG));
FlagNolinBeg=0;
I1(g.rib.n)=0;
I2(g.rib.n)=0;
% ����������� �������� ������������ ���������
if nPU==0
    FlagNolinBeg=0;
else
    FlagNolinBeg=1;
end
FlagNolinCur=FlagNolinBeg;
X0Cur=X0Beg;
% ��������� ���������� ����� ��������� �������� ����� ������� � �������
% �������
if isempty(Eq1)==1 % ���� ��� ��������� �� ������� ������ ��������
    Xres=fCalcEq2(Eq2, XDescr); % ������ ��������� �� ������� ������ ��������
    varargout{1}=Xres(1)+1i*Xres(2);
    varargout{2}=struct('mod',UmodCur,'d',dUCur);
    varargout{3}=struct(Qg);
    varargout{4}=NodeTypeCur;
    % ����������� ������������� ������ ��������������� � ������� ���������
    if nargout>4
        varargout{5}=1;
        if nargout>5
            varargout{6}=0;
        end
        if nargout>5
            varargout{7}=0;
        end
    end
    return;
end
% ����� ��������� ����������
% ������������� ��������� �������������
Z.R=@(J)Input.Z.R(1:g.rib.n);
Z.X=@(J)Input.Z.X(1:g.rib.n);
I1(g.rib.n)=0;
I2(g.rib.n)=0;
% ��������� ������ ��� ��������� ����������� �����
IEq2=spalloc(nEq2,2*Nn+1,nEq2*Nn);
if isempty(Eq2)==0
    ActEq2(1:nEq2)=true;
    % ���� ���� ������������ ����
    if nPU>0
        % �������� �������� ���������� ��������
        FirstLimPU=1;
        CountIterLim=0; % ������� ������� ����� ���� ����� ��� ���������� �������� ����������� ���������� ������
        FlagChangeLim=1; % ����, ������������ ��� ����������� ������������� �������� �������� �������� ���������� ��������
        UseStartLim=1; % ����, ������������ ��� ������������� ���������� ��������� �������� ��������
        [NodeTypeCur(PU), PUMod]=fResLim(NodeTypeCur(PU), Qg(PU),...
            struct('Qmin',Qmin(PU), 'Qmax', Qmax(PU)), UmodCur(PU),...
            Input.Uumod(PU),FirstLimPU, CountIterLim, ParamIterLim, UseStartLim);
    else
        % ��������� ����������� ����� ����� ������� �������� �������
        % ��������� �� 2-�� ������ ��������
        IEq2=[Eq2.Iv.R, Eq2.Iv.I]\[-Eq2.Iu.R, -Eq2.Iu.I, -Eq2.UConst];
    end
else
    ActEq2=[];
end
CountIter=0;
exit=0;
% �������� ���� ������� ��������� ������, � ��� �������������� ������������
% ��������������� ����� � ������ ��������� ���������� �� ���������, ������
% ����������� ����� ������� ������ �� ��������� ������� �� 0.
while exit==0
    CountIter=CountIter+1; % ������� ���������� ��������
    % ��������� ��������� ����� ����� PU, ��������� ���������� �������� �
    % ���������� ������������ ����� � ����������� � ����������� ������
    if (nPU>0)
        % ���� ���� PU ����� ����������
        if (sum(PUMod)>0)
            % ������������ ������ PU �����
            PUModProm=PU(PUMod==1);
            NumPU=1:nPU;
            NPUModProm=NumPU(PUMod==1);
            clear NumPU;
            % ����������� ���������� PU �����
            nPUCur=sum(NodeTypeCur(PU)==nTip.PU);
            % ��������������� �������� ������������ ������� ���������
            if nPUCur>0
                if FlagNolinCur==0
                    FlagNolinCur=1;
                end
            elseif FlagNolinCur>0
                FlagNolinCur=0;
            end
            % ��������������� ���������� �������� � ���������� � ����������
            % �����
            for J=1:length(PUModProm)
                PUProm=PUModProm(J); % ������� ������������ ����
                switch NodeTypeCur(PUProm)
                    % ���� ��� PU (������� � ������� �� ���������� ��������)
                    case nTip.PU
                        % ��������� ����������� �� ���������� �������� ����
                        % ��� ������� ��������� �� 2-�� ������ ��������,
                        % ��������� ���������������� ���������
                        Su.Q(PUProm)=Qn(PUProm);
                        X0Cur((nKont-nPU)*2+NPUModProm(J))=Qg(PUProm);
                        ActEq2((nKont-nPU+NPUModProm(J))*2-1:(nKont-nPU+NPUModProm(J))*2)=true;
                        % ���� ��� PU �� ������� �������
                    case nTip.PUmax
                        % ��������� ���������� �������� �� ������� ������,
                        % ���������� ���������������� ���������
                        Qg(PUProm)=Qmax(PUProm);
                        Su.Q(PUProm)=Qn(PUProm)-Qg(PUProm);
                        X0Cur((nKont-nPU)*2+NPUModProm(J))=Qg(PUProm);
                        ActEq2((nKont-nPU+NPUModProm(J))*2-1:(nKont-nPU+NPUModProm(J))*2)=false;
                    case nTip.PUmin
                        % ��������� ���������� �������� �� ������ ������,
                        % ���������� ���������������� ���������
                        Qg(PUProm)=Qmin(PUProm);
                        Su.Q(PUProm)=Qn(PUProm)-Qg(PUProm);
                        X0Cur((nKont-nPU)*2+NPUModProm(J))=Qg(PUProm);
                        ActEq2((nKont-nPU+NPUModProm(J))*2-1:(nKont-nPU+NPUModProm(J))*2)=false;
                    otherwise
                        warning('����� �������� ��� � ������������ ��������')
                end
            end
            clear NPUModProm PUModProm PUstrM PUstrG
        end
    end
    % ����� ��������� ��������� ����� ����� PU
    
    % ���� ���� ��������� �� 2-�� ������ �������� � ���������� ����
    % ������������ �����, �� ��� ��������� ��������� ����� �� ������
    % ���������� ��������
    if sum(PUMod)>0 && FlagNolinCur==0 && sum(ActEq2)>0
        % ������� �������� ������� ��������� �� 2-�� ������ ��������,
        % ��������� ��������� ����������� ����� ����� ���� ��������
        IEq2(ActEq2,:)=[Eq2.Iv.R(ActEq2,:), Eq2.Iv.I(ActEq2,:)]...
            \[-Eq2.Iu.R(ActEq2,:), -Eq2.Iu.I(ActEq2,:), -Eq2.UConst(ActEq2)];
    end
    % ����������� ����� � ����� (�� PU-����) � ����������� �� ����������
    IuR=(Su.P.*cos(dUCur)+Su.Q.*sin(dUCur))./UmodCur;
    IuI=(Su.P.*sin(dUCur)-Su.Q.*cos(dUCur))./UmodCur;
    
    % ����������� ������������ ��� ���� ������������� ���� (PU-����) ��� �������
    % �������� ����������
    for J=1:nPU
        if NodeTypeCur(PU(J))==nTip.PU
            Ig.ConstR(J)=(Su.P(PU(J))*cos(dUCur(PU(J)))+Qn(PU(J))...
                *sin(dUCur(PU(J))))/UmodCur(PU(J));
            Ig.ConstI(J)=(Su.P(PU(J))*sin(dUCur(PU(J)))-Qn(PU(J))...
                *cos(dUCur(PU(J))))/UmodCur(PU(J));
            Ig.VarR(J)=-sin(dUCur(PU(J)))/UmodCur(PU(J));
            Ig.VarI(J)=cos(dUCur(PU(J)))/UmodCur(PU(J));
        end
    end
    
    % � ����� ���� ������� �������� ��������� �� 2-�� ������ ��������
    % ������������ ������� ��������� �� ������� ������ �������, ���������
    % �����������
    if isempty(Eq2)==0 && sum(ActEq2)>0
        noPU=(nKont-nPU)*2; % ���������� "��������������" ���������
        % ����������� ����������� ������� ���������� ����, ��� ����
        % ������������
        LogPU=NodeTypeCur(PU)==nTip.PU;
        % ����������� ����������� ������� ���������� ���������� ������ �
        % ����������� �� �������� ���������
        LogActX(nEq2)=false;
        LogActX(1:noPU/2)=ActEq2(1:2:noPU-1);
        LogActX(noPU/2+1:noPU)=ActEq2(2:2:noPU);
        LogActX(noPU+1:noPU+nPU)=ActEq2(noPU+1:2:nEq2-1);
        LogActX(noPU+nPU+1:nEq2)=ActEq2(noPU+2:2:nEq2);
        % ����� �������� (�������� ��� ����������)
        if FlagNolinCur==1
            % ���������� ��������
            % ������� ������� ��������� �� 2-�� ������ �������� �� ������
            % ����������-���������, � �������� �������� ������ ��������
            % ���������, ����������� ������ �������� ���������� �res
            [Xres(LogActX),exitFlagEq2]=fCalcEq2(...
                Eq2.Iv.R(ActEq2,ActEq2(1:size(Eq2.Iv.R,2))),...
                Eq2.Iv.I(ActEq2,ActEq2(size(Eq2.Iv.R,2)+1:2*size(Eq2.Iv.R,2))),...
                Eq2.G.QR(ActEq2,LogPU),Eq2.G.QI(ActEq2,LogPU),...
                Eq2.G.dU(ActEq2,LogPU), Eq2.Iu.R(ActEq2,:), Eq2.Iu.I(ActEq2,:),...
                Eq2.UConst(ActEq2), IuR, IuI, ...
                struct('ConstR',Ig.ConstR(LogPU),...
                'ConstI',Ig.ConstI(LogPU),'VarR',Ig.VarR(LogPU),...
                'VarI',Ig.VarI(LogPU)), Descr(ActEq2,1:2),...
                X0Cur(LogActX), optionsLM); %#ok<AGROW>
            % ����������������� � ����������� NaN
            Xres(LogActX==false)=NaN; %#ok<AGROW>
            % ������ ��������������, ���� ������� ����������� � "������"
            % ��������
            if exitFlagEq2<1
                warning('������ ������� ������� ���������� ��������� �� 2-�� ������ ��������-������ ������� �� �������');
            end
        else
            % �������� ��������, ������� �������������� ����� �����������
            % ����� ��������, ��������� �� ����������� �� ������� ��������
            % � ���������, ���������� ����� ������� ������� ��������
            % ��������� �� 2-�� ������ ��������
            Xres(LogActX)=IEq2(ActEq2,1:Nn)*IuR(1:Nn)+IEq2(ActEq2,Nn+1:2*Nn)...
                *IuI(1:Nn)+IEq2(ActEq2,2*Nn+1);
            Xres(LogActX==false)=NaN;
        end
        % ������������� ����������� ������� - ������ � � ���������������
        % ����
        for J=1:nPU
            JJ=noPU+J;
            % ��� �������� ���������
            if ActEq2(noPU+2*J)==1
                % ����������� ������������ ��������, ���� ����������, �����
                % ������������ �����
                Qg(Descr(noPU+2*J))=Xres(JJ);
                dU(Descr(noPU+2*J))=Xres(JJ+nPU);
                IuR(Descr(noPU+2*J))=Ig.ConstR(J)+Ig.VarR(J).*Qg(PU(J));
                IuI(Descr(noPU+2*J))=Ig.ConstI(J)+Ig.VarI(J).*Qg(PU(J));
            end
        end
        % � �������� ������� ����������� �� ��������� �������� ���
        % ����������� �������� ��������� �������� �, ���������� �� ������
        % ��������
        X0Cur(LogActX)=Xres(LogActX);
    end
    % ����� ����� ������� ��������� �� 2-�� ������ ��������
    
    % ����������� ������������ ����� ������ �� ���������� ��������� �����
    % ����� �� ���������� �� 1-�� ������ ��������
    I1=Eq1.Iu*IuR;
    I2=Eq1.Iu*IuI;
    % ���� ���������� "��������������" ��������� ������ ���� %
    if noPU-1>0
        for J=1:Nb
            % ����������� ������������ ����� ������ �� ��������� ����� ��
            % ���������� �� 1-�� ������ ��������
            I1(J)=I1(J)+Eq1.InDep(J,:)*(Xres(1:noPU/2))';
            I2(J)=I2(J)+Eq1.InDep(J,:)*(Xres(noPU/2+1:noPU))';
        end
    end
    % �������� ������ �� ���� ������
    I.I1=@(J)I1(J);
    I.I2=@(J)I2(J);
    % ������ ������ � ���� ���������� � �����
    [UmodCur, dUCur]=fCalcU_PI(g, I, Z, Uop, NopG);
    % ����������� � ������������� ���� �������� �������� ����������
    UmodCur(NodeTypeCur==nTip.BU)=Input.Uumod(NodeTypeCur==nTip.BU);
    dUCur(NodeTypeCur==nTip.BU)=Input.dU(NodeTypeCur==nTip.BU);
    % ���� ���� ������������ ���� (��������� ���)
    if nPU>0
        % �������� �������� ���������� ��������, � ���������� ��������
        % ������ ����� ����� � ������ ��������� ��������� ���� ����
        CountIterLim=CountIterLim+1;
        if sum(PUMod)>0
            CountIterLim=0;
        end
        if CountIterLim>ParamIterLim+ParamNotCheckLim
            if FlagChangeLim~=0
                FlagChangeLim=0;
            end
        end
        if FlagChangeLim==1
            if CountIter<=ParamLimAl
               UseStartLim=1;
            else
               UseStartLim=0;
            end
        end
        [NodeTypeCur(PU), PUMod]=fResLim(NodeTypeCur(PU), Qg(PU),...
            struct('Qmin',Qmin(PU), 'Qmax', Qmax(PU)), UmodCur(PU),...
            Input.Uumod(PU),FirstLimPU,CountIterLim, ParamIterLim, UseStartLim);
        if sum(PUMod)>0
            FlagChangeLim=1;
        end
        if FirstLimPU~=0
            if CountIter>=ParamStartLim
                FirstLimPU=0;
            end
        end
    end
    % ���� ���� ����� �� ���������� (���� ���� ����� ���������� � �����
    % ������ ������������ ������� � ��������� ��������)
    if sum(PUMod)==0
        % ��� ���� ������������� ����� ���������� ������� ��� (��������� �������� ����
        % �� ���� ��������� ������)
        for J=1:nBU
            AR=g.nod(BU(J)).ar;
            Ibu.I1(BU(J))=0;
            Ibu.I2(BU(J))=0;
            for K=1:length(AR)
                % ���� ��������������� ���� - ������ �����
                if g.rib(AR(K)).ny1==BU(J);
                    Ibu.I1(BU(J))=Ibu.I1(BU(J))+I.I1(AR(K));
                    Ibu.I2(BU(J))=Ibu.I2(BU(J))+I.I2(AR(K));
                else % ���� �����
                    Ibu.I1(BU(J))=Ibu.I1(BU(J))-I.I1(AR(K));
                    Ibu.I2(BU(J))=Ibu.I2(BU(J))-I.I2(AR(K));
                end
            end
        end
        % � ����������� �� ������� ����������� �������� ������ ��������
        % �������� ������������� ���������� �������� ����� �������
        % ���������� �� ������� ����������
        if nargout<7
            [exit]=fTolCon_UU(g, struct('P',Su.P,'Q', Qn-Qg), Ibu, Z, struct('mod',UmodCur,'d', dUCur), optionsU);
        elseif nargout==7
            [exit, NbVal]=fTolCon_UU(g, struct('P',Su.P,'Q', Qn-Qg), Ibu, Z, struct('mod',UmodCur,'d', dUCur), optionsU);
        end
    end
    if (exit==1) && nPU>0
        % �������� �������� �������� PU �����
        FirstLimPU=1;
        [NodeTypeCur(PU), PUMod]=fResLim(NodeTypeCur(PU), Qg(PU),...
            struct('Qmin',Qmin(PU), 'Qmax', Qmax(PU)), UmodCur(PU),...
            Input.Uumod(PU),FirstLimPU,CountIterLim,ParamIterLim,1);
        if sum(PUMod)>0
            exit=0;
        end
    end
    % ���� ��������� ������������ ����� �������� - ��������� ������
    if (CountIter>=options.MaxIter) && exit~=1
        exit=2;
        break;
    end
end
% ������������� �������� ������
varargout{1}=I1+1i*I2; % ����
varargout{2}=struct('mod',UmodCur,'d',dUCur); % ����������
varargout{3}=Qg; % �������� �����������
varargout{4}=NodeTypeCur; % ���� �����
% � ������ ������������� - ������� ��������������� ����������
if nargout>4
    varargout{5}=exit; % ������� ������
    if nargout>5
        varargout{6}=CountIter; % ���������� ��������
    end
    if nargout>6
        varargout{7}=NbVal; % �������� �� ������� ����������
    end
end
end

function [Xres,exitflag] = fCalcEq2(EqInDepIvR, EqInDepIvI, EqIndepGQR, ...
    EqIndepGQI, EqInDepGdU, EqConstIuR, EqConstIuI, EqConstU, IuR, IuI, Ig,...
    Descr, X0, optionsLM)
% ������� ������������ ���������� � ���� ������ Matlab-��������� fsolve.
%
% [Xres,exitflag] = fCalcEq2(EqInDepIvR, EqInDepIvI, EqIndepGQR, EqIndepGQI, EqInDepGdU, EqConstIuR, EqConstIuI, EqConstU, IuR, IuI, Ig, Descr, X0, optionsLM)
% Xres - ������ ������� ������� ���������;
% exitflag - ��������, ��� �������� ������� ������� ����� 1, ��� ���������� ����� �������� ������������ ��� ��������� warning;
% EqInDepIvR - ������ �������������� ������������ ��������� ��� ��������� ����;
% EqInDepIvI - ������ ������ ������������ ��������� ��� ��������� ����;
% EqIndepGQR - ������ �������������� ������������ ��������� ��� ���������� �������� ������������ ����������;
% EqIndepGQI - ������ ������ ������������ ��������� ��� ���������� �������� ������������ ����������;
% EqInDepGdU - ������ ������������ ��������� ��� ���� ���������� ������������
% �����;
% EqConstIuR - ������ ���������� ������������ ��������� ��� �������������� ��������� ����� �����;
% EqConstIuI - ������ ���������� ������������ ��������� ��� ������ ��������� ����� �����;
% EqConstU - ������ ���������� ������������ ��������� �� ����������;
% IuR - �������������� ������������ ���� ����;
% IuI - ������ ������������ ���� ����;
% Ig - ��� ���������;
% Descr - ��������� ������� ����������;
% X0 - ������ ��������� �����������;
% optionsLM - ����� ��� fsolve.
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

% ������������� ����������
Xres(size(Descr,1),1)=0;
nPU=length(Ig.VarR);
EqGQ(size(Descr,1),nPU)=0;
FlagNolin=0;
Const(size(Descr,1),1)=0;
% ����������� ������� ����������� ������������ ���������
for J=1:length(Xres)
    switch Descr(J,2)
        case {1,3}
            Const(J)=EqConstU(J);
        case 2
            Const(J)=0;
        otherwise
            error('������ ������� ���� ������� 1,2 ��� 3');
    end
end
Const=Const+EqConstIuR*IuR+EqConstIuI*IuI;
% ����������� ������������ ��� ���������� ��������
for J=1:size(Descr,1)
    EqGQ(J,:)=EqIndepGQR(J,:).*(Ig.VarR)+EqIndepGQI(J,:).*(Ig.VarI);
end
% �������� handle �� �������, ����������� ������ �������� ������� ���������
% ��������� ��������� � �� ��������, ������������ �� ���������
funEq2=@(X)fhEq2_Matr(X, [EqInDepIvR, EqInDepIvI, EqGQ], EqInDepGdU, Const, nPU);
% ������ �������� �� ������ ����������-���������� � ��������� ������������
[Xres,fval,exitflag,output]=fsolve(funEq2,X0,optionsLM);
end

function [OutType, FlagMod] = fResLim(EntrType, Qg, Qbor, Ucurr, Uust,...
    First, CountIter,ParamIter, UseStart)
% ������������ ����������� ����� ��� ������� ������ ���������� ���� ��
% �������� �������� ��� ������ ��������.
%
% [OutType, FlagMod] = fResLimSt(EntrType, Qg, Qbor, Ucurr, Uust, First, CountIter,ParamIter)
%
% OutType - ������ �������������� ����� ���. ����� ����� �������������;
% FlagMod - ������ ��������� (logical) ��������� ���� �����������
% �� ��������;
% EntrType - ������ ������� (�������) ����� ������������ �����;
% Qg - ������ ���������� ��������� ��������� � ����� �� �����������
% ������� ������� ��������� �� 2-�� ������ ��������;
% Qbor - ���������, �������������� ������� ���������� �������� �����������
% Qbor.Qmax - ������ ������� ������;
% Qbor.Qmin - ������ ������ ������;
% Ucurr - ������ ������� ���������� ����������� �� ������� ��������;
% Uust - ������ ������� ���������� �����������;
% First - ������� ������ ��������;
% CountIter - ������� ����� ��������.
% ParamIter - ������� ����� ��������.
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

N=length(EntrType);
FlagMod(N)=false;
OutType=EntrType;
FlagOneNod=0;
FlagDf=0;
if UseStart==1
    for J=1:N
        switch EntrType(J)
            % ������� ��� ���������� - PU
            case nTip.PU
                if Qg(J)>Qbor.Qmax(J)&&(CountIter>=ParamIter||First==1)
                    OutType(J)=nTip.PUmax;
                    FlagMod(J)=true;
                    FlagDf=1;
                end
                % ������� ��� ���������� - PUmin
            case nTip.PUmin
                if Ucurr(J)<Uust(J)
                    if(CountIter>=ParamIter||First==1)||Ucurr(J)<0.8*Uust(J)
                        OutType(J)=nTip.PU;
                        FlagMod(J)=true;
                        FlagDf=1;
                    end
                end
                
            case nTip.PUmax
                if Ucurr(J)>1.2*Uust(J)
                    OutType(J)=nTip.PU;
                    FlagMod(J)=true;
                    FlagDf=1;
                end
            otherwise
                warning('������� ����� ��� ���� ��� �������� �������� ����������');
        end
    end
    if ((FlagDf==0)&&CountIter>=ParamIter)||(First==1)
        for J=1:N
            switch EntrType(J)
                % ������� ��� ���������� - PU
                case nTip.PU
                    if Qg(J)<Qbor.Qmin(J)
                        OutType(J)=nTip.PUmin;
                        FlagMod(J)=true;
                    end
                    % ������� ��� ���������� - PUmax
                case nTip.PUmax
                    if Ucurr(J)>Uust(J)
                        OutType(J)=nTip.PU;
                        FlagMod(J)=true;
                    end
                case nTip.PUmin
                otherwise
                    warning('������� ����� ��� ���� ��� �������� �������� ����������');
            end
        end
    end
else
    
    for J=1:N
        if FlagOneNod==0
            switch EntrType(J)
                % ������� ��� ���������� - PU
                case nTip.PU
                    if Qg(J)>Qbor.Qmax(J)&&(CountIter>=ParamIter)
                        OutType(J)=nTip.PUmax;
                        FlagMod(J)=true;
                        FlagOneNod=1;
                    end
                    % ������� ��� ���������� - PUmin
                case nTip.PUmin
                    if Ucurr(J)<Uust(J)
                        if(CountIter>=ParamIter)||Ucurr(J)<0.8*Uust(J)
                            OutType(J)=nTip.PU;
                            FlagMod(J)=true;
                            FlagOneNod=1;
                        end
                    end
                    
                case nTip.PUmax
                    if Ucurr(J)>1.2*Uust(J)
                        OutType(J)=nTip.PU;
                        FlagMod(J)=true;
                        FlagOneNod=1;
                    end
                otherwise
                    warning('������� ����� ��� ���� ��� �������� �������� ����������');
            end
        end
    end
    if (CountIter>=ParamIter&&FlagOneNod==0)
        for J=1:N
            if FlagOneNod==0
                switch EntrType(J)
                    % ������� ��� ���������� - PU
                    case nTip.PU
                        if Qg(J)<Qbor.Qmin(J)
                            OutType(J)=nTip.PUmin;
                            FlagMod(J)=true;
                            FlagOneNod=1;
                        end
                        % ������� ��� ���������� - PUmax
                    case nTip.PUmax
                        if Ucurr(J)>Uust(J)
                            OutType(J)=nTip.PU;
                            FlagMod(J)=true;
                            FlagOneNod=1;
                        end
                    case nTip.PUmin
                    otherwise
                        warning('������� ����� ��� ���� ��� �������� �������� ����������');
                end
            end
        end
    end
end
end