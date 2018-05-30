function Fsign = fSignEq2_PI(g)
% ������������ ����������� ������ ������������ �� ����� ������ � ����������
% �� 2-�� ������ �������� �� ��������� ����������� ������ � �����. ����
% ������������� ����� ����� ������������ � ������ ������ �������,
% �������������, ����� �����������������.
%
% Fsign = fSignEq2(g)
% Fsign - �������� ������, ������� ����� ��������� �������� -1 � 1;
% g - ������ CGraph, ���������� ��������������� ������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% October 2017.

Flag=0;
Fsign(1:g.rib.n)=1;
% ������������� ����� ������ ����� ��������
Fsign(1)=1;
for I=2:g.rib.n
    % ����������� ����������� ����������� ��������������� �����
    if (g.rib(I).ny1==g.rib(I-1).ny2)
        Fsign(I)=1;
    elseif (g.rib(I).ny2==g.rib(I-1).ny2)
        Fsign(I)=-1;
    elseif (g.rib(I).ny1==g.rib(I-1).ny1)
        Fsign(I)=-1;
    elseif (g.rib(I).ny2==g.rib(I-1).ny1)
        Fsign(I)=1;
    else
        error('������ ������� ������ �����');
    end
    % ����������� ����������� ��������������� ����� ������������ ������
    Fsign(I)=Fsign(I)*Fsign(I-1);
end
end