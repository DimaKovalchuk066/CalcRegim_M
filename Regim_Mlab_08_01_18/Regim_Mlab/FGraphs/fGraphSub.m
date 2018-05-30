function gSub = fGraphSub(g, hFN, hFV, hTypeN, hCommt, options)
% ������������ ��������� ��������� �� ��������� ��������� � ���������
% �������������� ���������.
%
% gSub = fGraphSub(g, hFN, hFV, hTypeN, hCommt, options)
%
% gSub - �������� ������ �������� ������ CGraph �������
% g - ���� ����������� �����( ������ ������ CGraph)
% hFN - handle ������ �� ������ ������ � ������ ����
% hFV - handle ������ �� ����� ������ � ������ ����
% hTypeN - ���� ����� � ������� nTip
% hCommt - ��������� �������������� ��������� � ������� cmStat
% options - ����� ������������ ������ ���������� �����
% options.Size - ����� ���������� ���� ��� ������ ����������� ������ ����� ������ �������
% ������ - ��������� ��������� ��� ����� ����������� ����� ����� �������;
% ����� - ��������� ��������� � ������ ����������� ����� ����� �������;
% options.Commt -  ����� ���������� ���� ��� ������ ��������� �������������� ��������� ��� ���������� ���������.
% ���� ��� - ��������� ���� �������������� ��������� �� ����������� ����������� � �������� ��������� ��������;
% �� ��� - ����������� ��������� ������������� ���������;
% options.Origin - ����� ���������� �� ����� ������ �������� � ����� ��������� ������� ��� ���������� ���������.
% �������� - ������ ��������� ����������� �� ������;
% ������ - ������ ��������� ����������� �� �������� �����;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017.

% ������������� ����������
nod(g.nod.n,1)=struct('an',0,'ar',0); % ������ ��������� ����� � ������ (��������� ����� �����)
nTypeGraph(g.nod.n)=0; % ������ ����� ����� (��������� ����� �����)
CommtGraph(g.rib.n,2)=0; % ������ ��������� �������������� ��������� (��������� ����� �����)
CommtLogicalGraph(g.rib.n)=0; % ���������� ������ ��������� �������������� ��������� (��������� ����� �����)
nZ=zeros(g.nod.n,1); % ������� ������ - ���������� ��������� ����� ���������� �����
rZ=zeros(g.rib.n,1); % ������� ������ - ���������� ��������� ����� ���������� ������
NoteCurrN=nZ; % ���������� ������ ������ ����� �� ������� �������� ������
NoteSummN=nZ; % ���������� ������ ������ ����� �� ���� ��������� ������
NoteCurrR=rZ; % ���������� ������ ������ ������ �� ������� �������� ������
NoteSummR=rZ; % ���������� ������ ������ ������ �� ���� ��������� ������
NumbSubGraph=0; % ������� ���������� ��������� �� ��������
SubGraph=nZ; % ������� ������� (����)
SubGraphRib=rZ; % ������� ������� (�����)
Nnsub=0; % ���������� ����� � ��������
Nrsub=0; % ���������� ������ � ��������
CPflag=0; % ���� ������� ��������� ������ �� ��
gSub(3)=CGraph; % ������ �������� ��������

% ������ ������� ��������� ����� � �����, ������� ����� �����
for i=1:g.nod.n
    nod(i)=struct('an',g.nod(i).an,'ar',g.nod(i).ar);
    nTypeGraph(i)=hTypeN(g.nod(i));
end

for i=1:g.rib.n
    CommtGraph(i,1:2)=hCommt(g.rib(i));
    CommtLogicalGraph(i)=1;
end

% ����� ��������� ������ ��� hFN � hFV
switch options.Origin
    case '����'
        hFN=(1:g.nod.n);
        hFV=@(I)[g.rib(I).ny1 g.rib(I).ny2];
    case '������'
        hFN=hFN;
        hFV=hFV;
    otherwise
        options.Origin='������';
        warning('�������������� ����� "��������" ������� fGraphSub. ������� �������� "������"');
end
% �������� ������������ ����� ����� Size
switch options.Size
    case'����'
    case '�����'
    otherwise
        options.Commt='����';
        warning ('������� �������������� ����� Size ��� ���������� ��������.\n ��������� "����", "�����". ����������� "�����"');
end

% ������� ���� ��������������� �������� ��  � ���������� (1, 0)
for i=1:g.rib.n
    switch options.Commt
        case'� ��'
            if (CommtGraph(i,1)==cmStat.OO)||(CommtGraph(i,1)==cmStat.O)||(CommtGraph(i,2)==cmStat.OO)||(CommtGraph(i,2)==cmStat.O)
                CommtLogicalGraph(i)=0;
            end
        case '��� ��'
            if (CommtGraph(i,1)==cmStat.OO)||(CommtGraph(i,2)==cmStat.OO)
                CommtLogicalGraph(i)=0;
            end
        otherwise
            if (CommtGraph(i,1)==cmStat.OO)||(CommtGraph(i,2)==cmStat.OO)
                CommtLogicalGraph(i)=0;
            end
            options.Commt='��� ��';
            warning ('������� �������������� ����� Commt ��� ���������� ��������.\n ��������� "� ��", "��� ��". ����������� "��� ��"');
    end
end

% ���� ��������� �� ��������
for i=1:g.nod.n % ���� �� ���� ������� �������
    % �������� ������������� ���������� ��������� � ������ gSub
    if nTypeGraph(i)==nTip.BU
        if length(gSub)<NumbSubGraph+length(nod(i).an)
            gSub(NumbSubGraph+2*(length(nod(i).an)+1))=CGraph;
        end
        for j=1:length(nod(i).an) % ���� �� ��������� ������ �� ������ �������
            if (nTypeGraph(nod(i).an(j))~=nTip.BU)&&(CommtLogicalGraph(nod(i).ar(j))==1)
                if CPflag==0
                    CPflag=1;
                end
                if (NoteSummN(nod(i).an(j))==0)
                    StartTravel=nod(i).an(j);
                    % ������ ������ ����� �� ������� ���� ��������������� � ��
                    % , ������� ������������� ��������, ��������� ����
                    [NoteCurrN, NoteCurrR] = fGraphTravel(nod, StartTravel, nTypeGraph, CommtLogicalGraph, options.Size);
                    % �������� ������� �������� �������� (����)
                    for k=1:g.nod.n
                        if (NoteCurrN(k)==1)
                            NoteSummN(k)=NoteCurrN(k);
                            Nnsub=Nnsub+1;
                            if strcmpi(options.Origin,'����')==1
                                SubGraph(Nnsub)=k;
                            else
                                SubGraph(Nnsub)=g.nod(k);
                            end
                        end
                    end
                    % �������� ������� �������� �������� (�����)
                    for k=1:g.rib.n
                        if (NoteCurrR(k)==1)
                            NoteSummR(k)=NoteCurrR(k);
                            Nrsub=Nrsub+1;
                            if strcmpi(options.Origin,'����')==1
                                SubGraphRib(Nrsub)=k;
                            else
                                SubGraphRib(Nrsub)=g.rib(k);
                            end
                        end
                    end
                    % �������� ��������
                    NumbSubGraph=NumbSubGraph+1;
                    gSub(NumbSubGraph) = CGraph(hFN, SubGraph(1:Nnsub), hFV, SubGraphRib(1:Nrsub));
                    SubGraph=nZ;
                    SubGraphRib=rZ;
                    Nnsub=0;
                    Nrsub=0;
                end
            elseif (nTypeGraph(nod(i).an(j))==nTip.BU) && strcmpi(options.Size, '�����')
                if (NoteSummR(nod(i).ar(j))==0)&&(CommtLogicalGraph(nod(i).ar(j))==1)
            CPflag=1;
            NumbSubGraph=NumbSubGraph+1;
            NoteSummN(i)=1;
            NoteSummN(nod(i).an(j))=1;
            NoteSummR(nod(i).ar(j))=1;
            gSub(NumbSubGraph) = CGraph(hFN, [i; nod(i).an(j)], hFV, nod(i).ar(j));
                end
            end
        end
        % ��������� ���������� � ����������� ��������� �� �� ��������
        % �� ������ ������� ���� �� � ���� ������� ���� ��� ����������
        % ��������� ��������
        if (CPflag==0)&& NoteSummN(i)==0
            NumbSubGraph=NumbSubGraph+1;
            NoteSummN(i)=1;
            gSub(NumbSubGraph) = CGraph(hFN, i, hFV, []);
        end
        CPflag=0;
    end
end
% �������� �������� �� ����� ����������������� ������� � ������
for i=1:g.nod.n
    if NoteSummN(i)==0
        Nnsub=Nnsub+1;
        if strcmpi(options.Origin,'����')==1
            SubGraph(Nnsub)=i;
        else
            SubGraph(Nnsub)=g.nod(i);
        end
    end
end
for i=1:g.rib.n
    if NoteSummR(i)==0
        Nrsub=Nrsub+1;
        if strcmpi(options.Origin,'����')==1
            SubGraphRib(Nrsub)=i;
        else
            SubGraphRib(Nrsub)=g.rib(i);
        end
    end
end

NumbSubGraph= NumbSubGraph+1;
gSub(NumbSubGraph) = CGraph(hFN, SubGraph(1:Nnsub), hFV, SubGraphRib(1:Nrsub));
gSub(NumbSubGraph+1:end)= [];

end % �����



