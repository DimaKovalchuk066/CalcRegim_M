%--------------------------------------------------------------------------
% MATLAB ������.
%
% ������ �������� ����������� ������ ��� ������� ������, ����������
% ��������� ��� �������� ������ ����, �����, ��������������� ����,
% ������������ ������ ����� � ������� ������ ����.
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% December 2017.
%--------------------------------------------------------------------------
% ������ ����� ������� � ������ ��������� � �������� ����� Matlab
go;
% �������� ��������� ����� ������� ������, ��� Method - ����� ����� ������
% (��������� ��� ���������� �������), NodeSheet - ����� ����� ��������
% ������ �� �����, BranchSheet - ����� ����� �������� ������ �� ������,
% TolFun - �������� ������� � ���.
%
inopts = struct('Method', methTip (0),'NodeSheet', 1, 'BranchSheet',2, 'TolFun', 1*10^-2);
% ���� ����� Excel �����
xlsFile = '\Excel Data\��������_������_5';
xlsOut = '\Excel Data\����������';
% ���� �������� ������ � ������ ������ CData
oDt=CData(xlsFile, inopts);
% �������� ������ ������� �� ��������� �������� ������ ������ CData
hM = CModelRS(oDt.NODE, oDt.BRAN, oDt.COMM);
clear oDt;
% �������� handle ���������� �� ������ ����� � ������ � ������, ����� �����
% � ��������� �������������� ���������
hFN = @(I)hM.NODE(I).Nn1;
hFV = @(I)[hM.BRAN(I).NbSt  hM.BRAN(I).NbF];
hType =@(I)hM.NODE(I).Type;
hComt = @(I)[hM.BRAN(I).CmStS  hM.BRAN(I).CmStF];
% �������� ����� �����
g = CGraph(hFN, (1:hM.NODE.n)', hFV, (1:hM.BRAN.n)');
% ����������� ����������� ������� ����� ����
optionPlot.MarkRib=0;
Plot=fGraphPlot(g, optionPlot);
% ���������� ������ ����� �� �������� (�������� ������ � ������� ���� CGraph)
optSubGraph = struct('Size', '�����','Commt','� ��','Origin', '������');
gSub= fGraphSub(g, hFN, hFV, hType, hComt, optSubGraph);
for J=1:length(gSub)-1
    % �������� ������ �� ����������� ���� ������� ������
    InputCalcReg=fInputCalcReg_PI(gSub(J),hM);
    [NODE, RIB, DiagnRegim]=fDriveRegim_PI(gSub(J),InputCalcReg);
    % ������ � ������ ����������� ������� ������ �� �����
    hM.NODE(gSub(J).nod).QgR=NODE.QgR;
    hM.NODE(gSub(J).nod).CurrType=NODE.CurrType;
    hM.NODE(gSub(J).nod).U=NODE.U;
    hM.NODE(gSub(J).nod).dU=NODE.dU;
    % ������ � ������ ����������� ������� ������ �� ������
    clear NODE;
    hM.BRAN(gSub(J).rib).Pn=RIB.Pn;
    hM.BRAN(gSub(J).rib).Pk=RIB.Pk;
    hM.BRAN(gSub(J).rib).Qn=RIB.Qn;
    hM.BRAN(gSub(J).rib).Qk=RIB.Qk;
    clear RIB;
end
% ������ ��������� ������ � ����
hM = CalcSum(hM);
% ������ ���������� �� ������ ������� ���������������
hM = CalcUT(hM);
% ������ ����������� ������� � xls-����
StatePlot = fExcelOut(hM, xlsOut);
if StatePlot==1
    display(['������ ��������. ���������� �������� ��������� � xls ����� ', xlsOut]);
else
    warning(['��������� ������ � ���� ����������� ������� ������ ',xlsOut]);
end
% ���������� ������ ���������