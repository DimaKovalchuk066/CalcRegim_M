function Plot = fGraphPlot(varargin)
% ������������ ����� ����� ���� CGraph � ���� ������� � ������� ������� plot
%
% gPlot = fGraphPlot(g,option)
% gPlot - �������� ������� ���� ������� (��� ������ �������� ����� � �������� �����);
% g - ������� ���� ���� CGraph;
% option - �����, ������������ ������������� ������ ����� ������;
%
% Written by D. Kovalchuk
% Research group of energetic faculty,
% department of BNTU.
% August 2017 Mod December 2017.

% ��������� �������� ������
% ��������� ������ � ������� ��������� �������
if isempty(varargin)
    return;
    % �������������� ������ ������� CGraph
elseif isa(varargin{1}, 'CGraph')
    % ���� ����� �������
    switch length(varargin)
        % ���� ����� �� ���������
        case 1
            g = varargin{1};
            option.MarkRib=1;
            % ������ ���� �����
        case 2
            g = varargin{1};
            option=varargin{2};
    end
else
    warning('�������� ������ ���� "CGraph".');
    Plot=0;
    return;
end

% ���� ���� �������� - ����� ��� �� �����
if isempty(g)==0
    % ���������� ������������ Matlab �����
gPlot = graph(g.rib(:).ny1, g.rib(:).ny2, g.rib, g.nod.n);
if option.MarkRib==1 && isempty(g.rib)==0
    Plot=plot(gPlot,'NodeLabel',g.nod,'EdgeLabel',gPlot.Edges.Weight,'MarkerSize',4,'EdgeAlpha',1);
else
    Plot=plot(gPlot,'NodeLabel',g.nod,'MarkerSize',4,'EdgeAlpha',0.5);
end
axis square;
else
    Plot=0;
    return;
end