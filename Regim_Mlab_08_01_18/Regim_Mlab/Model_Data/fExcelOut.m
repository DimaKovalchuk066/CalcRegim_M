function StatePlot = fExcelOut(hM, filename)
% ������������ ����� ����� ������� ���� CModelRS �� �����, ������ � �����
% ������ � excel ���� ��������, �������� ���������� � �������� ������.
%
% StatePlot = fExcelOut(hM, filename)
% hM - ������ ������ CModelRS;
% filename - ������ � ��������� ����� �����������;
% StatePlot - ���������� 1, ���� ������ ������ �������, 0 � ���� ������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% December 2017.

sheetN = 1; % ����� ����� � ������� �� �����
sheetB = 2; % ����� ����� � ������� �� ������
sheetO = 3; % ����� ����� � ������ �������
xlRange = 'A2';
Empty{1500,10}=0;
% ������ �����
StatePlot=xlswrite(filename,...
    Empty,...
    1,xlRange);
StatePlot=xlswrite(filename,...
    Empty,...
    2,xlRange);
StatePlot=xlswrite(filename,...
    Empty,...
    3,xlRange);
clear Empty;

% ����� ������ �� �����
for J=1:hM.NODE.n
    OutN{J,1}=hM.NODE(J).Nn1; % ����� ����
    % ����� ���� ����
    switch hM.NODE(J).CurrType
        case nTip.PQ
            OutN{J,2}='����';
        case nTip.BU
            OutN{J,2}='��';
        case nTip.PU
            OutN{J,2}='���';
        case nTip.PUmax
            OutN{J,2}='���+';
        case nTip.PUmin
            OutN{J,2}='���-';
    end
    OutN{J,3}=hM.NODE(J).Pn; % �������� �������� ��������
    OutN{J,4}=hM.NODE(J).Qn; % ���������� �������� ��������
    OutN{J,5}=hM.NODE(J).Pg; % �������� �������� ���������
    OutN{J,6}=hM.NODE(J).QgR; % ���������� �������� ���������
    OutN{J,7}=hM.NODE(J).Qmin; % ������ ������� ���������� ��������
    OutN{J,8}=hM.NODE(J).Qmax; % ������� ������� ���������� ��������
    OutN{J,9}=hM.NODE(J).Unn; % ������ ���������� � ����
    OutN{J,10}=hM.NODE(J).dU*180/pi; % ���� ���������� � ����
end
% ������ ������ �� ����� � ����
StatePlotN=xlswrite(filename,...
    OutN,sheetN,xlRange);
clear OutN;

% ������ ������ �� ������
xlRange = 'A2';
for J=1:hM.BRAN.n
    OutB{J,1}=hM.BRAN(J).Nb1; % ����� �����
    OutB{J,2}=hM.BRAN(J).NbSt; % ����� ������ �����
    OutB{J,3}=hM.BRAN(J).NbF; % ����� ����� �����
    % ������ ���� �����
    switch hM.BRAN(J).Type
        case bTip.T
            OutB{J,4}='�����';
        case bTip.L
            OutB{J,4}='�����';
    end
    OutB{J,5}=hM.BRAN(J).Pn; % �������� �������� ������
    OutB{J,6}=hM.BRAN(J).Qn; % ���������� �������� ������
    OutB{J,7}=hM.BRAN(J).Pk; % �������� �������� �����
    OutB{J,8}=hM.BRAN(J).Qk; % ���������� �������� �����
    OutB{J,9}=hM.BRAN(J).Is; % ��� �����
    OutB{J,10}=hM.BRAN(J).dU; % ������ ���������� �� �����
end
% ������ ������ � ����
StatePlotB=xlswrite(filename,...
    OutB,sheetB,xlRange);
clear OutB;
% ������ ����� ������
xlRange = 'A2';
    OutO{1}=hM.COMM.pgen; % �������� ���������
    OutO{2}=hM.COMM.ppotr; % �������� �������� ��������
    OutO{3}=hM.COMM.qgen; % ���������� �������� ���������
    OutO{4}=hM.COMM.qpotr; % ��������� �������� ������������
    OutO{5}=hM.COMM.dp; % ������ �������� ��������
    OutO{6}=hM.COMM.dq; % ������ ���������� ��������
    OutO{7}=hM.COMM.dpn; % ����������� ������ �������� ��������
    OutO{8}=hM.COMM.dpx; % ������ �������� �������� ��������� ����
    OutO{9}=hM.COMM.LINE.dp; % ������ �������� �������� � ������ 
    OutO{10}=hM.COMM.TRANS.dp; % ������ �������� �������� � ���������������
    % ������ ����� ������ � Excel
StatePlotO=xlswrite(filename,...
    OutO,...
    sheetO,xlRange);
clear OutO;
% �������� �������������� ���������� ������� ������, ������� ��������
% ���������� ������ ������� ������ �� ������
if StatePlotN==1 && StatePlotB==1 && StatePlotO==1
    StatePlot=1;
else
    StatePlot=0;
end
end