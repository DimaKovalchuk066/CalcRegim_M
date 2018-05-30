function InputReg = fInputCalcReg_PI(g, hM)
% �������. ������������ �������� ������ �� ���� ������ ��� ����� ��������
% ������ � ������� ���������� �������� ������ fDriveRegim, � �����
% ���������� �������� � ��������� ����� ��������.
%
% InputReg = fInputCalcReg_PI(g, hM)
% g - ���� ��������� �������� � ���� ������� ������ CGraph;
% hM - ������ �������������� ����������������� ���� ������ CModelRS;
% InputReg - ��������� ������ �� ���� ������:
% InputReg.COMM - ��������� ����� ������;
% InputReg.NODE - ��������� ������ �� ������ � �����;
% InputReg.BRAN - ��������� ������ �� ������ � ������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017.

% ����� ������
InputReg.COMM.Un= hM.COMM.Un;                  % ����������� ����������
InputReg.COMM.TolFun= hM.COMM.TolFun;          % �������� �������
% ������ � �����
InputReg.NODE.Uu=@(I)hM.NODE(g.nod(I)).Uu;     % ������ � ������ ����������
InputReg.NODE.dUu=@(I)hM.NODE(g.nod(I)).dUu;   % ������ � ���� ����������
% (��������� ����������� � ������� ��� ������������� �����)
InputReg.NODE.Pn=@(I)hM.NODE(g.nod(I)).PnX;    % ������ � �������� ��������
InputReg.NODE.Pg=@(I)hM.NODE(g.nod(I)).Pg;     % ������ � �������� ���������
InputReg.NODE.Qn=@(I)hM.NODE(g.nod(I)).QnX;    % ������ � ���������� ��������
InputReg.NODE.Qg=@(I)hM.NODE(g.nod(I)).QgR;    % ������ � ���������� ���������
InputReg.NODE.Qmin=@(I)hM.NODE(g.nod(I)).Qmin; % ������ � ������ ������� ���������� �������� ��� PU-����
InputReg.NODE.Qmax=@(I)hM.NODE(g.nod(I)).Qmax; % ������ � ������� ������� ���������� �������� ��� PU-����
InputReg.NODE.Type=@(I)hM.NODE(g.nod(I)).Type; % ������ � ���� ����
% ������ � ������
InputReg.BRAN.R=@(I)hM.BRAN(g.rib(I)).R;       % �������� ��������� ������������� �����
InputReg.BRAN.X=@(I)hM.BRAN(g.rib(I)).X;       % �������� ����������� ������������� �����
InputReg.BRAN.Pxx=@(I)hM.BRAN(g.rib(I)).Pxx;   % �������� �������� �������� ��������� ���� �����
InputReg.BRAN.Qxx=@(I)hM.BRAN(g.rib(I)).Qxx;   % �������� ���������� �������� ��������� ���� �����
InputReg.BRAN.kt=@(I)hM.BRAN(g.rib(I)).kt;     % �������� ������������ �������������
InputReg.BRAN.Type=@(I)hM.BRAN(g.rib(I)).Type; % ������ � ���� �����
end

