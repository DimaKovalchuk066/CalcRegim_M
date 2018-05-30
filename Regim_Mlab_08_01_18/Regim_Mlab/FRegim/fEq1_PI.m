function [Eq1] = fEq1_PI(g, Hord, InTypeN, Nop)
% ������� ������������ ����� ��������� ����� ��������� ������ �����
% ��������� ���� � ���� ����� ����� ������� �������� ������� ��������
% ������� LU-����������.
%
% [Eq1] = fEq1_PI(g, Hord, InTypeN, Nop)
%
% g - ���� ��������� ��������, �������������� �������� ���� CGraph;
% Hord - ������ ���� � �����;
% InTypeN - ���� �����;
% Nop - ����� �������� ����;
% Eq1 - ��������� ������ ��������� �� ������� ������ ��������;
% Eq1.Iu - ������� ������������� ��� ����� ����� ��� ��������� ����
% ��������������� �����;
% Eq1.InDep - ������� ������������� ��� ����� ����������� ������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

% ������������� ������ � �����
Nn=int32(g.nod.n);
TypeN=InTypeN(1:Nn);
Nb=int32(g.rib.n);
Nod=int32(g.nod);
Rib=int32(g.rib);
Ny1=int32(g.rib(:).ny1);
Ny2=int32(g.rib(:).ny2);
% �������� �������� �������������� ����� � ����� ���� PU, ����������
% ���������� �������� � ������ �� ��������
nBU=int32(0);
nPU=int32(0);
% ��� ���� �����
J=1:Nn;
% �������� ������� ������������� �����
BU=J(TypeN(J) == nTip.BU);
nBU=length(BU);
% �������� ������� ������������ �����
PU=J(TypeN(J) == nTip.PU);
nPU=length(PU);
nCycle=length(Hord);
clear J;
% ����������� ���������� ��������
nKont=nCycle+nPU;
for J=1:nBU
    nKont=nKont+length(g.nod(BU(J)).ar);
end
nKont=nKont-1;
%
% ��������� ������ ��� ������ ������ ����� ���������
Eq1B=spalloc(double(Nn), double(nKont-nPU), double((Nn)*2));
% �������� ������� �� ������, ��� ������� �������� ����������� ����������
Independ(Nb)=false;
CountBU=0;
% ��� ���� ������������� �����
for J=1:nBU
    % ��������� ����� �� �������������� ����
    AR=g.nod(BU(J)).ar;
    % ��� ���� ��������� ������
    for K=1:length(AR)
        % ���� �� ������ ��������� ����� �� �������� ����
        if (J~=Nop)||(K~=1)
            % ���������� ��������� Independ
            Independ(AR(K))=1;
            CountBU=CountBU+1;
            % �������� ������ ����� ��������� ��� �����, �������
            % ������������ � ������������� �����
            if TypeN(Ny1(AR(K)))~=nTip.BU
                Eq1B(Ny1(AR(K)), CountBU)=1;
            elseif TypeN(Ny2(AR(K)))~=nTip.BU
                Eq1B(Ny2(AR(K)), CountBU)=-1;
            end
        end
    end
    clear AR;
end
% ��� ���� ���� ������� ������������� ����� 1
Independ(Hord)=1;
% �������� ������ ����� �������� ��� �����, ������� ������������ � ������
for J=1:nCycle;
    Eq1B(Ny1(Hord(J)), CountBU+J)=1;% � �����
    Eq1B(Ny2(Hord(J)), CountBU+J)=-1;
end
% ��������� ������ ��� ����� ����� ���������
Eq1A=spalloc(double(Nn), double(Nb), double((Nn-nBU)*4));

% ����������� ��������� �� ������� ������ ��������, ��������� ������������
% � ���� �*�=�, ��� � � � ������� ��������� ��������, ��� ������� ������
% �������� �������� ������ � � � ����� ��������� �������� -1, 0, 1.
Counter=0;
% ��� ���� �����
for J=1:Nn
    AR=int32(g.nod(J).ar);
    % ��� ���� ��������� �����
    for K=1:length(AR);
        % ���� ���� �� ������������� � ��� ����� - ���������
        if TypeN(J)~=nTip.BU && Independ(AR(K))==0
            % ���� ��������������� ���� ������ ��������������� �����
            if J==Ny1(AR(K))
                Eq1A(J, AR(K))=-1;
            elseif J==Ny2(AR(K)) % ���� �����
                Eq1A(J, AR(K))=1;
            end
        end
    end
    clear AR;
end
% ���������� � ������ ����� ��������� ������� �����
Eq1B=[sparse(eye(Nn)),Eq1B];
% ��������� ������ ��� �������, ��������� ������� �������
Eq1Full=spalloc(double(Nb), double(Nn+nKont-nPU), double((Nb)*4));
% ������� ������� �������� ������� LU-����������
Eq1Full=Eq1A(TypeN~=nTip.BU,:)\Eq1B(TypeN~=nTip.BU,:);
clear Eq1A Eq1B;
% �������� �������� ��������
% �� ����� �����
Eq1.Iu=sparse(double(Nb), double(Nn));
Eq1.Iu=Eq1Full(:,1 : Nn);
% �� ����������� ������
Eq1.InDep=sparse(double(Nb), double(nKont-nPU));
Eq1.InDep=Eq1Full(:,Nn+1 : Nn+nKont-nPU);
clear Eq1Full;
CountBU=0;
% ���������� 1 �������������� ���������
% ��� ������������� �����
for J=1:nBU
    AR=g.nod(BU(J)).ar;
    for K=1:length(AR)
        if (J~=Nop)||(K~=1)
            CountBU=CountBU+1;
            Eq1.InDep(AR(K), CountBU)=1;
        end
    end
    clear AR;
end
% ��� ����
for J=1:nCycle;
    Eq1.InDep(Hord(J), CountBU+J)=1;
end
end