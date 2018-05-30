function varargout = fDriveRegim_PI(g, Input)
% ������������ ���������� ��������� ������� ������, �������������� ��������
% ������ � ������������ ���������� ������� ������, ������� ������������ �
% ������� fSolvReg_PI. � ������ ������� � ���� ��������, ������� ����������
% ������ ����������� ���������� �������� ��������� ����� � ������ � �����
% �������.
%
% varargout = fDriveRegim_PI(g, Input)
% g - ���� ��������� ��������, �������������� �������� ���� CGraph;
% Input - ��������� ������� ������, ������������ � ������� fInputCalcReg,
% �������������� ����� ������ �� ���� ������;
% Input.COMM - ����� ������;
% Input.NODE - ������ �� �����;
% Input.BRAN - ������ �� ������;
% varargout - cell-������ �������� ������
% varargout{1} - ��������� ������ �� �����;
% varargout{2} - ��������� ������ �� ������;
% varargout{3} - ��������� ��������������� ������ � ������� ������;
% varargout{1}.QgR - ������ �������������� ���������� ��������� �����������;
% varargout{1}.CurrType - ������ �������������� ����� ����� (������������);
% varargout{1}.U - ������ ������� ���������� � �����;
% varargout{1}.dU - ������ ��� ���������� � �����;
% varargout{2}.Pn - ������ ������ �������� �������� � ������ �����;
% varargout{2}.Pk - ������ ������ �������� �������� � ����� �����;
% varargout{2}.Qn - ������ ������ ���������� �������� � ������ �����;
% varargout{2}.Qk - ������ ������ ���������� �������� � ����� �����;
% varargout{3}.Flag - ���������� ���������� ������ ���������� ������� ������ (1 - ������ �������� ���������, 2 - ��������� ������������ ����� ��������);
% varargout{3}.Iter - ���������� ��������;
% varargout{3}.NbVal - ������ ���������� �� ������� ���������� � �����.

% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.
%%
Input.COMM.Nn=g.nod.n;
Input.COMM.Nb=g.rib.n;
Nop=1;
% ��������� ���������� ����� ������������ ���� � ��������
if Input.COMM.Nn==1
    % ������������� �������� ��������
    % �� �����
    varargout{1} = struct(...
        'QgR',      Input.NODE.Qg(1),...               % ���������� �������� ���������, ����
        'CurrType', Input.NODE.Type(1),...             % ������� ��� ���� � ����������
        'U',        Input.NODE.Uu(1),...            % ������ ���������� � ����, ��
        'dU',       Input.NODE.dUu(1)...              % ���� ���������� � ����, ���
        );
    % �� ������
    varargout{2} = struct(...
        'Pn',       [],...        % ����� P � ������, ���
        'Pk',       [],...        % ����� P � �����, ���
        'Qn',       [],...        % ����� Q � ������, ����
        'Qk',       []...        % ����� Q � �����, ����
        );
    % ��������������� ����������
    if nargout==3
        varargout{3}.Flag=11;
        varargout{3}.Iter=0;
        varargout{3}.NbVal=0;
    end
    return
end
% �������� �������� ���� ����, �������� �������
[gKont.BU, gKont.PU, gKont.Cycle] = fGraphKont(g, [], [], Input.NODE.Type, Nop);
% ���������� ��������
nKont=length(gKont.BU)+length(gKont.PU)+length(gKont.Cycle);
% ���� �������� ������ ��� ������� ��������� �� 1 ������
% ��������
HordG=[];
if length(gKont.Cycle)>0
    HordG(length(gKont.Cycle))=int32(0);
end

for J=1:length(gKont.Cycle)
    HordG(J)=gKont.Cycle(J).rib(1);
end
% ����������� ��������� � ������� �� 1 ������ ��������
% � ���������� ����� ��������� ��� ����� ������ ����� ���� ����� �
% ����������� ����������
Eq1= fEq1_PI(g, HordG, Input.NODE.Type, Nop);
% ������������� ���������� �����������
X0=[];
if nKont>0
    X0((nKont)*2,1)= 0;
end
for J=1:length(gKont.PU)
    X0((nKont-length(gKont.PU))*2+J)=Input.NODE.Qg(gKont.PU(J).nod(1));
    X0(nKont*2-length(gKont.PU)+J)=Input.NODE.dUu(gKont.PU(J).nod(1));%#ok<*AGROW>
end
% ������������� ���������� ����������� ��� ����������
J=1:Input.COMM.Nn;
U0mod(Input.NODE.Type(J)==nTip.PQ,1)=Input.COMM.Un;
U0mod(Input.NODE.Uu(J)~=0,1)=Input.NODE.Uu(Input.NODE.Uu(J)~=0);
dU0(J,1)=Input.NODE.dUu(J);
clear J;
%%
% �������� ��������� ������� ������ ��� �������� ��������� ������
Input_fSolvReg = struct(...
    'Umod',   U0mod,...
    'Uumod',  U0mod,...    
    'dU',     dU0,...    
    'Qmin',   Input.NODE.Qmin,...  
    'Qmax',   Input.NODE.Qmax,...  
    'TypeN',  Input.NODE.Type,...
    'Pn',     Input.NODE.Pn,...
    'Qn',     Input.NODE.Qn,...
    'Pg',     Input.NODE.Pg,...
    'Qg',     Input.NODE.Qg,...
    'Z',      struct('R', Input.BRAN.R,'X',Input.BRAN.X)...
    );
% ������������� �����, �������� � ������������ ���������� �������� ��
% �����������
optionsSol.TolFun=Input.COMM.TolFun;
optionsSol.MaxIter=100;
% ���� ���� ������� � �����
if nKont>0
    % �������� ���������� ��� ���������. ��������� - ����� �����(���
    % ��������� �����) ��� ���� (��� ������������ �����) � ��������
    % ��� ������������� �����
    for J=1:length(gKont.BU)
        Descr(2*J-1:2*J,1)=gKont.BU(J).rib(1);
        Descr(2*J-1:2*J,2)=1;
    end
    % ��� ������
    for J=1:length(gKont.Cycle)
        JJ=length(gKont.BU)+J;
        Descr(2*JJ-1:2*JJ,1)=gKont.Cycle(J).rib(1);
        Descr(2*JJ-1:2*JJ,2)=2;
    end
    % ��� PU-�����
    for J=1:length(gKont.PU)
        JJ=length(gKont.BU)+length(gKont.Cycle)+J;
        Descr(2*JJ-1:2*JJ,1)=gKont.PU(J).nod(1);
        Descr(2*JJ-1:2*JJ,2)=3;
    end
    % ����������� ��������� �� ������� ������ ��������
    Eq2=fEq2_PI(gKont, Eq1, g.nod.n, g.rib.n, ...
        struct('R', Input.BRAN.R, 'X', Input.BRAN.X),...
        struct('mod', Input.NODE.Uu, 'd', Input.NODE.dUu));
    % ��������� ������ �������� �� ����������� ��� ��������� �������� ����
    % � ����
    if length(gKont.PU)>0
        % ������� ���� PU ����� � ���� PQ
        Input_fSolvReg.TypeN=Input_fSolvReg.TypeN(':');
        Input_fSolvReg.TypeN(Input_fSolvReg.TypeN==nTip.PU)=nTip.PQ;
        MaxIterPrev=optionsSol.MaxIter;
        optionsSol.MaxIter=1;
        Input_fSolvReg.Qg=Input.NODE.Qg(':');
        % ������ 0 ��� ��������� ����������� ���������� ��������, ��� ���
        % ������������ ����� ���������, ��� ����� �������� ����������
        % �������� ����������� ��� ����� 7
        LogPU=Input.NODE.Type(':')==nTip.PU;
        Input_fSolvReg.Qg(LogPU)=0;
        Input_fSolvReg.Qg(Input_fSolvReg.Qg(LogPU)...
            <Input.NODE.Qmin(LogPU))=Input.NODE.Qmin(Input_fSolvReg.Qg(LogPU)...
            <Input.NODE.Qmin(LogPU));
        Input_fSolvReg.Qg(Input_fSolvReg.Qg(LogPU)...
            >Input.NODE.Qmax(LogPU))=Input.NODE.Qmax(Input_fSolvReg.Qg(LogPU)...
            <Input.NODE.Qmin(LogPU)); 
        %Input_fSolvReg.Qg(Input.NODE.Type(':')==nTip.PU)=...
        %    (Input_fSolvReg.Qmax(Input.NODE.Type(':')==nTip.PU)...
        %   -Input_fSolvReg.Qmin(Input.NODE.Type(':')==nTip.PU))/2;
        
        % ������ ������� ����������� ������ � ���� ���������� �����
        % ����������� ������ ��������� ���� ������������ ����� �����
        [~, Ucalc, ~, ~]=...
            fSolvReg_PI(Eq1, Eq2, [], Descr, g, Input_fSolvReg, optionsSol);

        Input_fSolvReg.Umod=Ucalc.mod;
        Input_fSolvReg.dU=Ucalc.d;
        % ������� �������� ������
        Input_fSolvReg.TypeN=Input.NODE.Type;
        optionsSol.MaxIter=MaxIterPrev;
        for J=1:length(gKont.PU)
            X0(nKont*2-2*length(gKont.PU)+J)=Input_fSolvReg.Qg(gKont.PU(J).nod(1));
            X0(nKont*2-length(gKont.PU)+J)=Input_fSolvReg.dU(gKont.PU(J).nod(1));%#ok<*AGROW>
        end
        clear MaxIterPrev;
    end
    % ������� ��������� ������ ��� ������� �������� (�� 2-�� ������
    % ��������)
    [Icalc, Ucalc, QgCalc, TypeCalc, FlagTerm, CountIter, NbVal]=...
        fSolvReg_PI(Eq1, Eq2, X0, Descr, g, Input_fSolvReg, optionsSol); %#ok<*ASGLU>
else % ���� ����������� ������� � �����
    X0Descr=[];
    % ������� ��������� ������ ��� ���������� �������� (����� ���������
    % ����� (�������� ����������) � ��������� �� ������� ������ ��������)
    [Icalc, Ucalc, QgCalc, TypeCalc, FlagTerm, CountIter, NbVal]=...
        fSolvReg_PI(Eq1, [],[],[], g, Input_fSolvReg, optionsSol);
end
J=1:g.rib.n;
NY1=g.rib(:).ny1;
NY2=g.rib(:).ny2;
% �������� ������ (����������� ������� ��������, ������: ���� �������
% ����������� � ������)
Scalc.n(J)=Ucalc.mod(NY1(J)).*(cos(Ucalc.d(NY1(J)))+...
    1i*sin(Ucalc.d(NY1(J)))).*(conj(Icalc(J)));
Scalc.k(J)=Ucalc.mod(NY2(J)).*(cos(Ucalc.d(NY2(J)))+...
    1i*sin(Ucalc.d(NY2(J)))).*(conj(Icalc(J)));
clear J NY1 NY2;
% ������������� �������� ��������� ������ - ������ �� ������
% �� �����
J=1:g.nod.n;
varargout{1} = struct(...
    'QgR',      QgCalc(J),...               % ���������� �������� ���������, ����
    'CurrType', TypeCalc(J),...             % ������� ��� ���� � ����������
    'U',        Ucalc.mod(J),...            % ������ ���������� � ����, ��
    'dU',       Ucalc.d(J)...               % ���� ���������� � ����, ���
    );
% �� ������
J=1:g.rib.n;
varargout{2} = struct(...
    'Pn',       real(Scalc.n(J)),...        % ����� P � ������, ���
    'Pk',       real(Scalc.k(J)),...        % ����� P � �����, ���
    'Qn',       imag(Scalc.n(J)),...        % ����� Q � ������, ����
    'Qk',       imag(Scalc.k(J))...         % ����� Q � �����, ����
    );
% ����� ��������������� ���������� ��� �������������
if nargout==3
    varargout{3}.Flag=FlagTerm;
    varargout{3}.Iter=CountIter;
    varargout{3}.NbVal=NbVal;
end
% ���� ���� ���������� �������� ����� "������" ������ - �����
% ��������������
if FlagTerm~=1
    warning('������ � ������� ������� ����� � ���������� fSolvReg, ���������� �������� ����� ���� ���������');
end
end
