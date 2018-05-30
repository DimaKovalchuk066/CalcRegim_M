function [NoteNod, NoteRib] = fGraphTravel(nod, Start, nType, CommtLogical, option)
% ������������ ����� ����� � �������. ���������� ���������� ������� ���
% ����� � ������ (1 - ������� ������� ��� ������, 0 - ������� �� �������)
% [NoteNod, NoteRib] = fGraphTravel(nod, Start, nType, CommtLogical, option)
% nod - ��������� �������� ����� � ������ (node.an - ����, node.ar - �����)
% Start - ��������� ���� ������%
% nType - ������ ����� �����
% CommtLogical - ��������� �������������� ���������
% option - ����� ���������� ���� ��� ������ ����������� ������ ����� ������ �������
% ������ - ��������� ��������� ��� ����� ����������� ����� ����� �������;
% ����� - ��������� ��������� � ������ ����������� ����� ����� �������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017.

% ������������� ����������
Exit=0; % ������� ���������� ������ �����
n=length(nod); % ���������� �����
nZ=zeros(n,1); % ������� ������ - ���������� ��������� ����� ���������� �����
rZ=zeros(length(CommtLogical),1); % ������� ������ - ���������� ��������� ����� ���������� ������
NoteNod=nZ; % ���������� ������ ��������� ���������� ����� ��� ������
NoteRib=rZ; % ���������� ������ ��������� ���������� ������ ��� ������
StepAn=ones(n,1); % ������, ������������ ��� ������� ���� ����� ������� ��������������� ���� ���� �� ������������� ����� �� �������
CurrN=Start; % ������� ���� � ������
PrevN=nZ; % ���������� ���� � ������
Shag=0; % ����������, ������������� ����� (��� ������ �� ������������)
Return=1; % �������, ������������ ������������� �������� � ����������� ����

while Exit==0
    Return=1;
    Shag=Shag+1;
    if(NoteNod(CurrN)==0)
        NoteNod(CurrN)=1; % ��������� ������� �� ����
    end
    if (nType(CurrN)~=nTip.BU)||(CurrN==Start)||(strcmp(option,'����')) % ���������� ����� ������� ������
        for j=StepAn(CurrN):length(nod(CurrN).ar) % ������� ��������� �����, ����� ���������� � �������� �������� � ������� ��� �� ��������
            if(CommtLogical(nod(CurrN).ar(j))==1) 
                NoteRib(nod(CurrN).ar(j))=1; % ��������� ������� �� �����             
                if(NoteNod(nod(CurrN).an(j))==0)
                StepAn(CurrN)=StepAn(CurrN)+1; % ������� � ���������� ����
                PrevN(nod(CurrN).an(j))=CurrN;
                CurrN=nod(CurrN).an(j);
                Return=0;
                break;
                end
            end
        end
    end
    if (Return==1) % ������� � ���� ����
        if CurrN~=Start % ����� � ������, ���� �� ���������� ���� ��� �����
            CurrN=PrevN(CurrN);
        else
            Exit=1;
            break;
        end
    end
    if (Shag>=1000000) % ������ �� ������������
        error ('������������ (���������� ����� ��������� 10^6). ������� ����: %s',mat2str(CurrN));
        break;
    end
end
return % �����