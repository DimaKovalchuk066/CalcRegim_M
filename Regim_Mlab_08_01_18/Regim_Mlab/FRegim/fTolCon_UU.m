function varargout = fTolCon_UU(g, Sin, Ibu, Zin, Uin, Options)
% ������� ������������ �������� �������� ����������� ���������� � �����
% ����� ������� ���������� �� ������� ����������, ���������� �� ��������
% �������� ����������.
%
% varargout = fTolCon_UU(g, Sin, Ibu, Zin, Uin, Options)
%
% g - ���� ��������� ��������, �������������� �������� ���� CGraph;
% Sin - ��������� �������� ��������� �����;
% Ibu - ��������� �������� ����� ������������� �����;
% Zin - ��������� �������� �������������;
% Uin - ��������� �������� ���������� �����;
% Options - ����� �������;
% Options.TolFun - �������� ������� � ���;
% varargout - cell-������ �������� ������ �������;
% varargout{1} - ��������, ������������ ���������� �������� ��������,
% 0 - �������� �� ����������, 1 - �������� ����������;
% varargout{2} - ������ ���������� �� ������� ����������, ��������� �������
% �������� ��������
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% November 2017.

switch nargin
    case 6
        TolFun=Options.TolFun;
    case 5
        TolFun=10^(-2);
    case 4
    otherwise
    error('�������� ���������� ������� ����������');
end
% ����� ��������� �������� ��� ��� �������� �� ������� ���������� ��� �����
% �� ���� ����������� ���������� ��� �������� �����, � �� ��������
% ���������
U=Uin.mod.*cos(Uin.d)+1i*Uin.mod.*sin(Uin.d);
S=Sin.P+1i*Sin.Q;
K=1:g.rib.n;
Z(K)=Zin.R(g.rib(K))+1i*Zin.X(g.rib(K));
clear K;
Nb_UU(g.nod.n)=0;
% ���������� �������� ���� ��� ��������������� �����
Nb_UU(Ibu.I1==0)=-(conj(S(Ibu.I1==0)./U(Ibu.I1==0)));
% ���������� �������� ���� ��� ����������� �����
Nb_UU(Ibu.I1~=0)=Nb_UU(Ibu.I1~=0)+Ibu.I1(Ibu.I1~=0);
Nb_UU(Ibu.I2~=0)=Nb_UU(Ibu.I2~=0)+1i*Ibu.I2(Ibu.I2~=0);
for J=1:g.nod.n;
    AN=g.nod(J).an;
    AR=g.nod(J).ar;
    % ���������� ������������ �� ���������� �������� �����
    for K=1:length(AN)
        Nb_UU(J)=Nb_UU(J)+1000*(U(AN(K))-U(J))./Z(AR(K));
    end
    clear AN AR;
end
% ��������� ��������� �� �������� ���������� ��� �������� �� ���� �
% ��������
Nb_UU=(Nb_UU).*U';
% ������� �������� ������ �� ������� ��������� ��������� �� ����������
% �������� ��������
if sum(abs(Nb_UU)>TolFun)==0
    TolOk=1;
else
    TolOk=0;
end
    varargout{1}=TolOk;
if nargout==2
   varargout{2}=abs(Nb_UU);
end
end