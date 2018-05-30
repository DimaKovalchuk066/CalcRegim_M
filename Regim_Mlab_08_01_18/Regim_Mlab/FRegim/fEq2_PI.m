function Eq2 = fEq2_PI(gKont, Eq1, Nn, Nb, Z, UIn)
% ������� ������������ ����������� ��������� �� 2-�� ������ �������� � ����
% ��������� � ���������������� ������.
%
% Eq2 = fEq2_PI(gKont, Eq1, Nn, Nb, Z, UIn)
%
% gKont - ��������� ������, �������������� �������;
% Eq1 - ��������� ��������� �� 1-�� ������ ��������;
% Nn - ���������� ����� � ��������� ��������;
% Nb - ���������� ������ � ��������� ��������;
% Z - ��������� ��������, �������������� ������ �������������;
% Z.R - �������� �������������;
% Z.X - ���������� �������������;
% UIn - ��������� �������� ���������� � �����;
% UIn.mod - ������ ������� ����������;
% UIn.d - ������ ��� ����������;
% Eq2 - ���������, �������������� ��������� �� 2-�� ������ ��������;
% Eq2.Iv - ��������� �������� ������������� ��� ����� ����������� ������;
% Eq2.Iv.R - ��� �������������� �����;
% Eq2.Iv.I - ��� ������ �����;
% Eq2.G - ��������� �������� ������������� �� ������������ �����;
% Eq2.G.QR - ��� �������������� ����� ���� ����������;
% Eq2.G.QI - ��� ������ ����� ���� ����������;
% Eq2.G.dU - ��� ���� ����������;
% Eq2.Iu - ��������� �������� ������������� ��� ����� �����;
% Eq2.Iu.R - ��� �������������� �����;
% Eq2.Iu.I - ��� ������ �����;
% Eq2.UConst - ����������� ������������ �� ����������;
%
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

% ������������� �������� ������
R(1,:)=Z.R(1:Nb);
X(1,:)=Z.X(1:Nb);
U=UIn.mod(1:Nn);
dU=UIn.d(1:Nn);
% ����������� ���������� �������� ���� ����� � ���������� ���������
nBUKont=length(gKont.BU);
nPU=length(gKont.PU);
nCycle=length(gKont.Cycle);
nKont=nBUKont+nPU+nCycle;
nEq=2*nKont;
% ��������� ������ ��� ���� ��������� ��������� �� 2-�� ������ ��������
Eq2.Iv.R=spalloc(double(nEq), double(nKont-nPU), double((nEq)*(nKont-nPU)));
Eq2.Iv.I=spalloc(double(nEq), double(nKont-nPU), double((nEq)*(nKont-nPU)));
Eq2.G.QR=spalloc(double(nEq), double(nPU), double((nEq)*(nPU)));
Eq2.G.QI=spalloc(double(nEq), double(nPU), double((nEq)*(nPU)));
Eq2.G.dU=spalloc(double(nEq), double(nPU), double((nEq)*(nPU)));
Eq2.Iu.R=spalloc(double(nEq), double(Nn), double(nEq*int32(Nn/2)));
Eq2.Iu.I=spalloc(double(nEq), double(Nn), double(nEq*int32(Nn/2)));
Eq2.UConst=spalloc(double(nEq), 1, double(nEq));
% ����������� ���������
% ��� �������� ���� �� (����� �������������� ������)
for J=1:nBUKont
    % ����������� ����� ���� ����� � ���������
    Sign=fSignEq2_PI(gKont.BU(J));
    K=1:gKont.BU(J).rib.n;
    RibN=gKont.BU(J).rib(K);
    % ���������� � ���������� ������������ �� ����� �����
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iu.R(2*J-1,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*J-1,:)=-(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iu.R(2*J,:)=(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*J,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    
    % ���������� � ���������� ������������ �� ����� ������
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iv.R(2*J-1,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*J-1,:)=-(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iv.R(2*J,:)=(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*J,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    clear RibN Sign;
    
    % ���������� ������������ �� �������� ���������� �� ������ �������
    % �������� ������ ����� ���� � ��� �� �� �� ������ ������ ����� ��-��
    if ((gKont.BU(J).rib(1).ny1~=gKont.BU(J).nod.n)&&...
            (gKont.BU(J).rib(1).ny2~=gKont.BU(J).nod.n))...
            ||gKont.BU(J).rib.n==1
        % ����������� ����� ������������ �� ���������� � ���������
        if gKont.BU(J).rib(1).ny1==1
            SignU=1;
        elseif gKont.BU(J).rib(1).ny2==1
            SignU=-1;
        else
            error(['������ ����������� ����� ������������',...
                '�� �������� ����������']);
        end
        % ������� ������������ �� ����������
        % � ������ ��������� ��� ������� (�������������� �����)
        Eq2.UConst(2*J-1,1)=1000*(U(gKont.BU(J).nod.n)*...
            cos(dU(gKont.BU(J).nod.n))-U(gKont.BU(J).nod.n)*...
            cos(dU(gKont.BU(J).nod(1))))*SignU;
        % �� ������ ��������� ��� ������� (������ �����)
        Eq2.UConst(2*J,1)=1000*(U(gKont.BU(J).nod.n)...
            *sin(dU(gKont.BU(J).nod.n))-U(gKont.BU(J).nod.n)...
            *sin(dU(gKont.BU(J).nod(1))))*SignU;
    end
end

% ��� �������� ���� ����, ���������� ������� � �����
for J=1:nCycle
    % ����������� ����� ���� ����� � ���������
    JJ=nBUKont+J;
    Sign=fSignEq2_PI(gKont.Cycle(J));
    K=1:gKont.Cycle(J).rib.n;
    RibN=gKont.Cycle(J).rib(K);
    % ���������� ������������ �� ����� �����
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iu.R(2*JJ-1,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*JJ-1,:)=-(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iu.R(2*JJ,:)=(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*JJ,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    
    % ���������� ������������ �� ����� ������
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iv.R(2*JJ-1,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*JJ-1,:)=-(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iv.R(2*JJ,:)=(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*JJ,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    clear K RibN Sign;
end

% ��� �������� ����� ������������� ����� � PU-�����
for J=1:nPU
    % ����������� ����� ���� ����� � ���������
    JJ=nBUKont+nCycle+J;
    Sign=fSignEq2_PI(gKont.PU(J));
    K=1:gKont.PU(J).rib.n;
    RibN=gKont.PU(J).rib(K);
    % ���������� ������������ �� ����� �����
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iu.R(2*JJ-1,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*JJ-1,:)=-(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iu.R(2*JJ,:)=(X(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    Eq2.Iu.I(2*JJ,:)=(R(RibN).*Sign(K))*Eq1.Iu(RibN,:);
    
    % ���������� ������������ �� ����� ������
    % � ������ ��������� ��� ������� (�������������� �����)
    Eq2.Iv.R(2*JJ-1,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*JJ-1,:)=-(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.Iv.R(2*JJ,:)=(X(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    Eq2.Iv.I(2*JJ,:)=(R(RibN).*Sign(K))*Eq1.InDep(RibN,:);
    clear K RibN Sign;
    % ������� ������������ �� ����������
    % ����������� ����� ������������ �� ���������� � ���������
    if gKont.PU(J).rib(1).ny1==1
        SignU=1;
    elseif gKont.PU(J).rib(1).ny2==1
        SignU=-1;
    end
    % ���������� ������������ �� ������ ����������
    % � ������ ��������� ��� ������� (�������������� �����)
    Nnod=gKont.PU(J).nod.n;
    Eq2.UConst(2*JJ-1,1)=1000*(U(gKont.PU(J).nod(Nnod))...
        *cos(dU(gKont.PU(J).nod(Nnod))))*SignU;
    % �� ������ ��������� ��� ������� (������ �����)
    Eq2.UConst(2*JJ,1)=1000*(U(gKont.PU(J).nod(Nnod))...
        *sin(dU(gKont.PU(J).nod(Nnod))))*SignU;
    % ���������� ������������ �� ���� ���������� � ������ � ������
    % ��������� ��� �������
    Eq2.G.dU(2*JJ-1:2*JJ,J)=-1000*U(gKont.PU(J).nod(1))*SignU;
end
for J=1:nPU
    % ���������� ������������ �� ���������� �������� ������������ �����
    Eq2.G.QR(:,J)=Eq2.Iu.R(:,gKont.PU(J).nod(1));
    Eq2.G.QI(:,J)=Eq2.Iu.I(:,gKont.PU(J).nod(1));
end
end