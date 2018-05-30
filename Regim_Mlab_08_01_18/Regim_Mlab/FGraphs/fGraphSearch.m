function gPath = fGraphSearch(g, hFN, hFV, START, GOAL, option)
% ������������ ����� ���������� (����������� ���������� ��������) �����
%(����� ����� � ������) �� ������ ���������� ���� �� ����� ��� ����������
% �����, ���������� ��������� � ����� ������� ������, ���������� ���� �
% �����, �������� � ������ �� ���������. ���������� ����� FIFO (�������).
%
% gPath = fGraphSearch(g, hFN, hFV, START, GOAL, option)
% gPath - �������� ������ ���� CGraph, ���������� ���� �� START �� ���� GOAL;
% g - ������ CGraph, ���������� ��������� ��������, � ������� �����
% ����������� ����� ���������;
% hFN - handle ������ �� ������ ������ � ������ ����;
% hFV - handle ������ �� ����� ������ � ������ ����;
% START - ����� ���������� ���� � ������������ � ��������� ����������
% ������;
% GOAL - ������ ������� �����-�����;
% option - ��������� ������� �������� ������ ��� �������� ������� ����� � ������
% ("����" ��� "������");
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017.

ParentN(g.nod.n)=0;
ParentR(g.nod.n)=0;
CurrN=0;
Queue=FIFO;
Queue.len;
ParentN(START)=-1;
ParentR(START)=-1;
Queue=add(Queue,START);
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
    CurrN=Queue.last; % ������� ���� - ������ � ������� ������
    AN=g.nod(CurrN).an;
    AR=g.nod(CurrN).ar;
    % ������� ���� ��������� �����
    for (j=1:length(AN))
        if (ParentN(AN(j))==0) % ���� �� ���� � ������ ����
            Queue=add(Queue, AN(j)); % �������� � ������� ����
            ParentN(AN(j))=CurrN; % ����������� ������������� ���� ��� ���� AN(j)
            ParentR(AN(j))=AR(j); % ����� ��� ���� AN(j)
        end
    end
    clear AN;
    clear AR;
    Queue=del(Queue); % ����������� ������ ������� � �������
end

% �������������
CurrN=0;
MarshN(10) = 0; % ���� � ��������
MarshR(10) = 0; % ����� � ��������
gPath(length(GOAL))= CGraph; % �������� ������ CGraph �������
% ��� ���� ������� �����
for i=1:length(GOAL)
    CurrN=GOAL(i); % ������ ���� - ������� ����
    j=1;
    % ������ � ��������� ���������� �����
    if length (MarshN)>10
    MarshN (11:end)=[];
    MarshR (11:end)=[];
    end
    MarshN(10) = 0;
    MarshR(10) = 0;
    MarshN(j)= CurrN; % ������ ���� - ������� ����
    % ���� �� ��������� ���������� ���� ������������ ����������� ������� ��
    % ���� �� ����������� � ���������� ����
    while (CurrN~= START)
        % ������ � �������� ���������� �����
        if length(MarshN)<=j 
            MarshN(length(MarshN)+10)=0;
            MarshR(length(MarshR)+10)=0;
        end
        % �������� �������� � ����. ����
        MarshR(j)=ParentR(CurrN); % ��������� ������� � ������ ������
        j=j+1;
        CurrN=ParentN(CurrN);  % ����� ������� ���� - �������� ������� 
        MarshN(j)=CurrN; % ��������� ������� � ������ �����
    end
    % �������� ������ ��������� �� ��������
    MarshN((j+1):end)=[];
    MarshR(j:end)=[];
    % ���������� ����� �������� ������
    if strcmpi(option, '����')
        MarshN=MarshN;
        MarshR=MarshR;
    else
        for j=1:length(MarshN)
        MarshN(j)=g.nod(MarshN(j));
        if j~=length(MarshN)
        MarshR(j)=g.rib(MarshR(j));
        end
        end
    end
    gPath(i) = CGraph(hFN, MarshN, hFV, MarshR);
end
end