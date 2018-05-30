function gCycle = fGraphCycle(g, hFN, hFV, START, option)
%���������� ��������� � ����� ����������� ���������� ���������
% ���������� ����������� ����� ������ � �����. ������������ ����� �����
% � ������ ��� ����������� ����������������� ������, ����� -
% ����������� ����� ������ ������ � ����� � ������� �� ������
% ����� � ��������� ����� �� ������ ��������� ����� ������������ �� ����
% ���������. ��� ����������� 2-� ��������� ���� ��������� �����������.
%
% gCycle = fGraphCycle(g, hFN, hFV, START, option)
% gCycle - �������� ������ ���� CGraph, ���������� ��� ����������� �������;
% g - ������ CGraph, ���������� ��������� ��������, � ������� �����
% ����������� ����� ������;
% hFN - handle ������ �� ������ ������ � ������ ����;
% hFV - handle ������ �� ����� ������ � ������ ����;
% START - ����� ���������� ���� � ������������ � ��������� ����������
% ������;
% option - ��������� ������� �������� ������ ��� �������� ������� ����� � ������
% ("����" ��� "������");
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017.

% ������������� ����������
ParentN(g.nod.n)=0;
ParentR(g.nod.n)=0;
CurrN=0;
Queue=FIFO;
Queue.len;
ParentN(START)=-1;
ParentR(START)=-1;
Queue=add(Queue,START);
UsedR(g.rib.n)=0;
% ���������� ��������
nKont=g.rib.n-g.nod.n+1;
NotUsedR(nKont)=0;
% ����� ��������� ������ ��� hFN � hFV
switch option
    case '����'
        hFN=(1:g.nod.n);
        hFV=@(I)[g.rib(I).ny1 g.rib(I).ny2];
    case '������'
        hFN=hFN;
        hFV=hFV;
    otherwise
        option ='������';
        warning('�������������� ����� "��������" ������� fGraphSub. ������� �������� "������"');
end

% ����� ����� � ������ � �������������� ������� ������ FIFO (�������)
while(isempty(Queue)==0)
    CurrN=Queue.last;  % ������� ���� - ������ � ������� ������
    AN=g.nod(CurrN).an;
    AR=g.nod(CurrN).ar;
    % ������� ���� ��������� �����
    for j=1:length(AN)
        if (ParentN(AN(j))==0) % ���� �� ���� � ������ ����
            Queue=add(Queue, AN(j)); % �������� � ������� ����
            ParentN(AN(j))=CurrN; % ����������� ������������� ���� ��� ���� AN(j)
            ParentR(AN(j))=AR(j); % ����� ��� ���� AN(j)
            UsedR(AR(j))=1; % ������� ������������ �����
        end
    end
    clear AN;
    clear AR;
    Queue=del(Queue); % ����������� ������ ������� � �������
end

% ����������� ������� ������������ ��� ������ ������
CounterNotUsed=0;
for i=1:g.rib.n
    if UsedR(i)==0
        CounterNotUsed=CounterNotUsed+1; % ������� ������������ ������
        NotUsedR(CounterNotUsed)=i; % ������ ������������ (����������������� ������)
    end
end
% ������������� ���������� ���-�� �������� � ����������� ���-��� ������������
% ������
if length(NotUsedR)~=nKont
    warning('�������� ���������� �������� (������� �������� �������)');
end
% ��������� ������
for i=1:length(NotUsedR) % ���� �� ���������� ����������������� ������
    % �������������
    CountN1=1;
    CountN2=1;
    Stop1=0;
    Stop2=0;
    Fin=0;
    StopLine=0;
    % ������ � ��������� ���������� �����
    MarN1(1:10)=0;
    MarN2(1:10)=0;
    MarR1(1:10)=0;
    MarR2(1:10)=0;
    if length (MarN1)>10
        MarN1(1)=[];
        MarN2(1)=[];
        MarR1(1)=[];
        MarR2(1)=[];
    end
    
    % ������������
    Visited(1:g.nod.n)=0; % ������ ���������� �����
    CountN1=1; % ���������� ������ �� ������� ��������
    CountN2=1; % ���������� ������ �� ������� ��������
    MarN1(CountN1)=g.rib(NotUsedR(i)).ny1; % ��������� ����� ������� �������� - ������ ����� ����������������� �����
    MarN2(CountN2)=g.rib(NotUsedR(i)).ny2; % ��������� ����� ������� �������� - ������ ����� ����������������� �����
    while (Fin==0) % ���� ���������� �������� ����� ����� ����
        % �������� �� ������������ ���������� ����
        if (ParentN(MarN1(CountN1))== START)
            Stop1=1; % ������� ����������� ��� ���������� ���������� ���� �� ������� ��������
        end
        if (ParentN(MarN2(CountN2))== START)
            Stop2=1; % ������� ����������� ��� ���������� ���������� ���� �� ������� ��������
        end
        % �������� �� ������������ ���������� ���� �� 2 ������
        if (ParentN(MarN1(CountN1))== START) && (ParentN(MarN2(CountN2))== START)
            warning ('��������� ��������� ���� fGraphCycle �� ���� �����');
        end
        % ������ � ��������� ���������� �����
        if (length (MarN1)+1)<=(CountN1)
            MarN1(length(MarN1)+10)=0;
            MarR1(length(MarR1)+10)=0;
        end
        if (length (MarN2)+1)<=(CountN2)
            MarN2(length(MarN2)+10)=0;
            MarR2(length(MarR2)+10)=0;
        end
        
        if Stop1==0 % ���� �� ��������� ��������� ����
            if Visited(ParentN(MarN1(CountN1)))==0; % ���� ������������ ���� �� ������� �� �������
                CountN1=CountN1+1; % ��������� ������������ ���� � ����� ����� � �������
                MarN1(CountN1)=ParentN(MarN1(CountN1-1));
                MarR1(CountN1-1)=ParentR(MarN1(CountN1-1));
                Visited(MarN1(CountN1))=1; % ������� ������������ = 1
            else
                MarR1(CountN1)=ParentR(MarN1(CountN1)); % ��������� ����� � �������
                StopLine=1; % �������� =1 ���� ��������� ������� ��������� �� ������ �������� � 2, ���� �� ������
                Fin= ParentN(MarN1(CountN1)); % ���� �� ������� ��������� ����������� ���������
                break;
            end
        end
        if Stop2==0 % ���� �� ��������� ��������� ����
            if Visited(ParentN(MarN2(CountN2)))==0; % ���� ������������ ���� �� ������� �� �������
                CountN2=CountN2+1; % ��������� ������������ ���� � ����� ����� � �������
                MarN2(CountN2)=ParentN(MarN2(CountN2-1));
                MarR2(CountN2-1)=ParentR(MarN2(CountN2-1));
                Visited(MarN2(CountN2))=1; % ������� ������������ = 1
            else
                MarR2(CountN2)=ParentR(MarN2(CountN2)); % ��������� ����� � �������
                StopLine=2; % �������� =1 ���� ��������� ������� ��������� �� ������ �������� � 2, ���� �� ������
                Fin= ParentN(MarN2(CountN2)); % �������� ���� � �������
                break;
            end
        end
    end
    % ������ � �������� ���������� ����� - �������� ������ ���������
    MarN1(CountN1+1:end)=[];
    MarN2(CountN2+1:end)=[];
    % �� ������� ��������
    if StopLine==1 % ���� ����������� ��������� ��������� �� ������
        % �������� ������ ������ (���-�� ������ ������� �� �������� StopLine)
        MarR1(CountN1+1:end)=[];
        MarR2(CountN2:end)=[];
        if MarN1(CountN1)~=START % ���� ���� ����������� ��������� �� ��������� (����� �������� ������ ��-��� �� �����)
            % �������� ������ ��������� �� �������� �� �������� ������� ��
            % ���������
            for j=CountN2:1 % ������� �������� �� ����� �� ������ �� ����������� ����
                if MarN2(j)==Fin % ���� ������� ���� ����������� ��������, �� ����
                    break;
                else
                    MarN2(j)=[]; % �������� ������ ������ � �����
                    MarR2(j-1)=[];
                end
            end
        end
        % �� ������� ��������
    elseif StopLine==2 % ���� ����������� ��������� ��������� �� ������
        MarR1(CountN1:end)=[];
        MarR2(CountN2+1:end)=[];
        if MarN2(CountN2)~=START % ���� ���� ����������� ��������� �� ��������� (����� �������� ������ ��-��� �� �����)
            % �������� ������ ��������� �� �������� �� �������� ������� ��
            % ���������
            for j=CountN1:1
                if MarN1(j)==Fin  % ���� ������� ���� ����������� ��������, �� ����
                    break;
                else
                    MarN1(j)=[]; % �������� ������ ������ � �����
                    MarR1(j-1)=[];
                end
            end
        end
        % ���������� ����� �������� ������
        if strcmpi(option, '����')
            MarN1=MarN1;
            MarN2=MarN2;
            MarR1=MarR1;
            MarR2=MarR2;
        else
            for j=1:length(MarN1)
                MarN1(j)=g.nod(MarN1(j));
                if j~=length(MarN1)
                    MarR1(j)=g.rib(MarR1(j));
                end
            end
            for j=1:length(MarN2)
                MarN2(j)=g.nod(MarN2(j));
                if j~=length(MarN)
                    MarR2(j)=g.rib(MarR2(j));
                end
            end
        end       
    else % ���� ��� ����� ��������, �� ������ ����������� �������
        warning ('������ ����������� �������');
    end
    % �������� ������� CGraph (���� � ����� ������� �������� �������� � �������� ������� ��� ����������� ������������������ ��������� � �����)
    gCycle(i)=CGraph(hFN, [MarN1(1:end), MarN2(end:-1:1)], hFV, [g.rib(NotUsedR(i)), MarR1(1:end), MarR2(end:-1:1)]);
end
end