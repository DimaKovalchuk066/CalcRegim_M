function [gKontBU, gKontPU, gCycle] = fGraphKont(g, hFN, hFV, TypeN, Nop)
% ������������ �������� ������� ����������� �������� ���� �����
% �� ���������� �������� �����, ��������� ���������� � ���� �������� ������
% � ���������� �� �����.
%
% [gKontBU, gKontPU, gCycle] = fGraphKont(g, hFN, hFV, TypeN)
% gKontBU - �������� ������ ���� CGraph, ����������� ������� ���� ��-��, �
% ����� �������, ��������� �������, ���������� �� ������ ��;
% gKontPU - �������� ������ ���� CGraph, ���������� ������� ���� ��-��
%(�������� ���������);
% gCycle - �������� ������ ���� CGraph, ���������� �����;
% g - ������ CGraph, ���������� ��������� ��������, �� ������� �����
% ����������� ��������� ��������;
% hFN - handle ������ �� ������ ������ � ������ ����;
% hFV - handle ������ �� ����� ������ � ������ ����;
% TypeN - ���� ����� � ������� nTip.
% Nop - (���������) ����� �������� ������ �������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017 Mod December 2017.

% ������������� ����������
if g.nod.n==0||g.rib.n==0
   gKontBU=[];
   gKontPU=[];
   gCycle=[];
   return;
end
Nmod(g.nod.n)=0;
Rmod(g.rib.n,2)=0;
count=0;
nBU=0;
nPU=0;
BU=[];
PU=[];
PromGraph=CGraph;
gKontBU=PromGraph(1:0);
gKontPU=PromGraph(1:0);
gCycle=PromGraph(1:0);
if isempty(hFN)||isempty(hFV)
    option='����';
else
    option='������';
end
switch option
    case '������'
    case '����'
        hFN=(1:g.nod.n);
        hFV=@(I)[g.rib(I).ny1 g.rib(I).ny2];
    otherwise
        hFN=(1:g.nod.n);
        hFV=@(I)[g.rib(I).ny1 g.rib(I).ny2];
        warning('����������� ������ ����� � ��������� �������� ������� ����');
end
 % ������ ��� �������� �������� ������� ����� ���� CGraph
% ������� ���������� � �������� ������� ����� ���� BU � PU
for i=1:g.nod.n
    if strcmpi(option,'������')
        iProm=g.nod(i);
    else
        iProm=i;
    end
    if TypeN(iProm) == nTip.BU
        nBU=nBU+1;
        BU(nBU)=i;
    elseif TypeN(iProm) == nTip.PU
        nPU=nPU+1;
        PU(nPU)=i;
    end
end

    
% ������� ���������� ������ � ����� (� ������ ��������, ���������
% ���������� �� ������ �� �������)
nKont123=g.rib.n-g.nod.n+1;
% ������ �������� ������������ ������ ��������, ���� ������������ ���� ��
% ���� ��� ��������
if (nBU>1)||(nPU>0)||(nKont123>0)
    % ����� �������� ���� ��� ��������� ��������
    OU=BU(1);
    % ������������� ���������������� �������� ����� � ������ � �����
    % ��� ���������� ���������� ���������� ������� � ����������� ���������� �������
    Nmod=1:g.nod.n;
    for i=1:g.rib.n
        Rmod(i,1)=g.rib(i).ny1;
        Rmod(i,2)=g.rib(i).ny2;
    end
    CurrN = length(Nmod); % ������������� ���������� �������� ���������� �����
    NumbNewNod=0; % ������������� ���������� ���������� ����� �����
    % ������ ������������ ���������� ����� ����� � ������
    for i=1:length(BU)
        NumbNewNod=NumbNewNod+length(g.nod(BU(i)).ar) - 1;
    end
    % �������� ���������� ������ � ������ ��������, ������������
    % ����������� ������� � ����������� ���������� �������
    nKont123=nKont123-NumbNewNod;
    % ���������� ��������� � ���. ������ ������� ����� � ����� �
    % ������������ � ���-��� ����������� �����
    if NumbNewNod>0
        Nmod(length(Nmod)+NumbNewNod)=0;
    end
    % ���� �������� ���������� �������
    for i=1:length(BU)
        AR=g.nod(BU(i)).ar; % ������ ��������� ������
        % ���� �� �� ������� ����� ����� �����, �� ��������� ����
        if length(AR)>1
            for j=2:(length(AR)) % ���� �� ���� ��������� ������
                % ����������� ���������� ����� �� 1 (��������� ���� ������������ � ����� �������!!!, Nmod - ������
                % ������������ ����� ����� ���������������� � ��������� ������
                CurrN=CurrN+1;
                Nmod(CurrN)= BU(i);
                % �������� ���� �� ������ ����� ��������� �� ������� ��,
                % ��� ����� �� ��� ��������� � ���������� ����
                if Rmod(AR(j),1)== BU(i) % ���� ������ - ��
                    Rmod(AR(j),1)=CurrN;
                elseif Rmod(AR(j),2)==BU(i) % ���� ����� - ��
                    Rmod(AR(j),2)=CurrN;
                end
            end
        end
    end
    % �������� handle �� ���. ������ ������
    hFVmod=@(I)[Rmod(I,1) Rmod(I,2)];
    % �������� ����������������� ����� (��������� ����� � ������
    % ������������� Nmod � Rmod � ���������� �����, �� ����������� ����������� �����)
    gMod=CGraph([1:CurrN], [1:CurrN], hFVmod, [1:size(Rmod,1)]);
    
    % ���� ���� ������� ���� ��-�� � ��-�� ��������� �������� ������ �����, �������� ������� ����� � ������ - "����",
    % ������� ������ ������, ���������� ������� ���� (������� ��-��, ��-��),
    % ���� ��� - ������� ������ ������ CGraph ������� �����
    if (nBU-1+nPU+NumbNewNod)<1
        gKontCP = PromGraph(1:0);
    else
        gKontCP =  fGraphSearch(gMod, hFN, hFV, OU, [BU(2:end),[g.nod.n+1:CurrN],PU(1:end)], '����');
    end
    
    % ���� ���� ����� � ����� ��������� �������� ������ ������, �������� ������� ����� � ������ - "����",
    % ������� ������ ������, ���������� ������� �����,
    % ���� ��� - ������� ������ ������ CGraph ������� �����
    if (nKont123)<1
        gCycleProm = PromGraph(1:0);
    else
        gCycleProm = fGraphCycle(gMod, hFN, hFV, OU, '����');
    end
    clear gMod; clear Rmod; clear AN; clear AR;
    
    % �������������� �������, ���������� ����������� � ������ ������ �����
    % � ������ (� ������������ fKont ������������ "����") ��������� ����
    % �������, ����� ����� � ������ ������, ��� � ������, ���� ��� ��������
    % ��-�� ��-��, �� �������������� ������ ������� �����
    if (nBU-1+nPU+NumbNewNod)<1
        gKontRet = PromGraph(1:0);
    else
        gKontRet(nBU-1+nPU+NumbNewNod) = CGraph;
    end
    
    for i=1:length(gKontCP) % ���� �� ���� �������� ��-��, ��-��
        % �������������� ����������, ����������� ��� �������� ������������
        % ������� ����� � ������
        NodReturn(1:gKontCP(i).nod.n)=0;
        RibReturn(1:gKontCP(i).rib.n)=0;
        Count=0;
        % �������� �������� ���������, ���������� ����� ���������� ��������
        if length(NodReturn)>gKontCP(i).nod.n
            RibReturn(gKontCP(i).nod.n+1:end)=[];
        end;
        if length(RibReturn)>gKontCP(i).rib.n
            RibReturn(gKontCP(i).rib.n+1:end)=[];
        end;
        % �������� ��������� �����, ���������� ������� � ������
        for j=1:gKontCP(i).nod.n
            % ���� ���� �� ��������� (��������� � �����), �� �������� �����
            % ����, ��������� � ������, � ������ � ����������
            if gKontCP(i).nod(j)<=g.nod.n
                Count=Count+1; % ������� ���������� ����������� �����
                % ���������� ������ ���� � ������, ������ � ������
                % ���� ���� �� ������� (����� �� ����������� ��� � �����),
                % ���������� ������ ����� � ���. ����� � ������� ����� �
                % ��������� �����, ����� ���������� � ������� ����� � ������
                if strcmpi(option, '������')
                NodReturn(Count)= g.nod(gKontCP(i).nod(j));
                else
                NodReturn(Count)= gKontCP(i).nod(j);
                end
            elseif Nmod(gKontCP(i).nod(j))~=OU
                Count=Count+1;
                if strcmpi(option, '������')
                NodReturn(Count)= g.nod(Nmod(gKontCP(i).nod(j)));
                else
                NodReturn(Count)= Nmod(gKontCP(i).nod(j));
                end
            end
        end
        % �������� �������� ��������� ����� ���������� �������� �����
        % ��������� ���������� ��������� NodReturn ��� �����
        if length(NodReturn)>Count
            NodReturn(Count+1:end)=[];
        end;
        % ������ � ������ ������� ������ �� ���������� �����, �������� �
        % ������
        if strcmpi(option, '������')
        RibReturn=g.rib(gKontCP(i).rib(:));
        else
        RibReturn=gKontCP(i).rib(:);
        end
        % �������� ������ ������, ����������� ��������� � ������� ������
        gKontRet(i) = CGraph(hFN, NodReturn, hFV, RibReturn);
    end
    clear gKontCP;
    clear NodReturn;
    clear RibReturn;
    % ��������� ������� ������ �� 2 ������������ ��-�� � ��-��
    if nBU-1+NumbNewNod>0
        gKontBU = gKontRet(1:(nBU-1+NumbNewNod));
    else
        gKontBU = PromGraph(1:0);
    end
    if nPU>0
        gKontPU = gKontRet((nBU+NumbNewNod):end);
    else
        gKontPU = PromGraph(1:0);
    end
    clear gKontRet;
    % �������������� �������, ���������� ����������� � ������ ������ �����
    % � ������ (� ������������ fKont ������������ "����"), ���� ��� ������
    % , �� �������������� ������ ������� �����
    if (nKont123)<1
        gCycle = PromGraph(1:0);
    else
        gCycle(nKont123) = CGraph;
    end
    % �������� �� ���� ������ �����
    for i=1:length(gCycleProm)
        % �������������� ����������, ����������� ��� �������� ������������
        % ������� ����� � ������
        NodReturn(1:gCycleProm(i).nod.n)=0;
        RibReturn(1:gCycleProm(i).rib.n)=0;
        % ������� �������� �������� ����� ���������� ��������
        if length(NodReturn)>gCycleProm(i).nod.n
            RibReturn(gCycleProm(i).nod.n+1:end)=[];
        end;
        if length(RibReturn)>gCycleProm(i).rib.n
            RibReturn(gCycleProm(i).rib.n+1:end)=[];
        end;
        % �������� ������ � ����� � ������� ����� � ������, ����������
        if strcmpi(option, '������')
        NodReturn= g.nod(gCycleProm(i).nod(:));
        RibReturn=g.rib(gCycleProm(i).rib(:));
        else
        NodReturn= gCycleProm(i).nod(:);
        RibReturn=gCycleProm(i).rib(:);
        end

        % �������� ������ � ����� � ������� ������ � ������, ����������
        % �������� ������� ������, ����������� ��������� (�����) � �������
        % ������ (������ ������� �������� �������� � ������������)
        gCycle(i) = CGraph(hFN, NodReturn, hFV, RibReturn);
    end
end
end