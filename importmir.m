% -------------------------------------------------------------------------
% Função:
% importmir
% -------------------------------------------------------------------------
% Rotina MATLAB 2010 para ler arquivos CSV e montar label, scale e X
% ---------------------------------------------------------------
% Lê todos os arquivos CSV da pasta atual
files = dir('*.csv');

% Inicializa variáveis
X = [];
scale = [];
label = {};

for k = 1:length(files)
    % Nome do arquivo atual
    fname = files(k).name;
    
    % Abre o arquivo
    fid = fopen(fname, 'r');
    
    % Pula as duas primeiras linhas
    fgetl(fid);
    fgetl(fid);
    
    % Lê todo o restante como strings
    data = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    
    % Converte a primeira coluna em duas partes
    nrows = length(data{1});
    scale_tmp = zeros(nrows,1);
    values_tmp = zeros(nrows,1);
    
    for i = 1:nrows
        line = data{1}{i};
        parts = regexp(line, ',', 'split');
        scale_tmp(i) = str2double(parts{1});
        values_tmp(i) = str2double(parts{2});
    end
    
    % Se for o primeiro arquivo, define o vetor scale
    if isempty(scale)
        scale = scale_tmp;
    else
        % Verifica se bate com o primeiro
        if any(scale ~= scale_tmp)
            warning('Escalas diferentes encontradas no arquivo %s', fname);
        end
    end
    
    % Concatena no X
    X = [X values_tmp];
    
    % Adiciona o nome do arquivo ao label
    [~, name, ~] = fileparts(fname);
    label{end+1,1} = name;
end

X = X';

clear ans data fid files fname i k line name nrows parts scale_tmp values_tmp

% Resultado final:
% - scale: vetor com a escala
% - X: matriz com valores (cada coluna = 1 arquivo)
% - label: nomes dos arquivos
