% -------------------------------------------------------------------------
% Fun��o:
% importnir
% -------------------------------------------------------------------------
% Uso:
% Esta fun��o importa dados de arquivos .csv de an�lises NIR na pasta atual, realiza o processamento necess�rio e 
% os adiciona ao workspace do MATLAB. 
% -------------------------------------------------------------------------
% A fun��o executa as seguintes etapas:
% 1. Identifica todos os arquivos .csv na pasta atual.
% 2. Inicializa as matrizes de sa�da Scale e Data.
% 3. Para cada arquivo .csv:
%    a. Abre o arquivo e l� seu conte�do.
%    b. Verifica se os decimas est�o separados por ponto.
%    c. Caso os decimais estejam separados por v�rgula substitui por ponto.
%    d. Realiza a convers�o logaritmica dos espectros.
%    e. Adiciona os dados processados � matriz X.
% 4. Importa um vetor com os r�tulos das amostras.
% 5. Adiciona as vari�veis Scale, X e Label ao workspace base do MATLAB.
% -------------------------------------------------------------------------
% Escrito por:
% H�lio Milito Martins de Amorim Neto
% Departamento de Qu�mica, Instituto de Ci�ncias Exatas
% Universidade Federal de Minas Gerais
% Janeiro 2025
% -------------------------------------------------------------------------

% 1�: Listar todos os arquivos CSV na pasta atual
asc = dir('*.csv');
numfile = length(asc);

% Inicializar matriz de dados processados
dadosX = cell(numfile, 1);

% Loop para processar cada arquivo CSV
for k = 1:numfile
    arquivo = asc(k).name;
    
    % Abrir o arquivo para leitura
    fid = fopen(arquivo, 'r');
    if fid == -1
        error('N�o foi poss�vel abrir o arquivo: %s', arquivo);
    end
    
    % Ler todas as linhas do arquivo
    linhas = textscan(fid, '%s', 'Delimiter', '\n');
    linhas = linhas{1};
    fclose(fid);
    
    % Verificar o n�mero de v�rgulas na segunda linha (ignorando o cabe�alho)
    num_virgulas = length(strfind(linhas{2}, ','));
    
    % Se houver 41 v�rgulas, substituir as v�rgulas nas posi��es �mpares por pontos
    if num_virgulas == 41
        for i = 2:length(linhas) % Come�ar da segunda linha (ignorar cabe�alho)
            % Encontrar as posi��es de todas as v�rgulas na linha
            virgula_posicoes = strfind(linhas{i}, ',');
            
            % Substituir v�rgulas nas posi��es �mpares por pontos
            for j = 1:2:length(virgula_posicoes)
                posicao = virgula_posicoes(j); % Posi��o da v�rgula a ser substitu�da
                linhas{i}(posicao) = '.'; % Substituir v�rgula por ponto
            end
        end
        
        % Salvar o arquivo modificado
        novo_arquivo = strrep(arquivo, '.csv', '_modificado.csv');
        fid = fopen(novo_arquivo, 'w');
        if fid == -1
            error('N�o foi poss�vel criar o arquivo modificado: %s', novo_arquivo);
        end
        
        for i = 1:length(linhas)
            fprintf(fid, '%s\n', linhas{i});
        end
        fclose(fid);
        
        % Atualizar o nome do arquivo para o arquivo modificado
        arquivo = novo_arquivo;
    elseif num_virgulas ~= 20
        % Se o n�mero de v�rgulas n�o for 20 nem 41, exibir um aviso
        warning('O arquivo %s tem %d v�rgulas. Nenhuma a��o foi tomada.', arquivo, num_virgulas);
    end
    
    % 4�: Aplicar a rotina de processamento dos dados
    dadosX{k} = importdata(arquivo);
    
    % Verificar se os dados foram importados corretamente e t�m colunas suficientes
    if isfield(dadosX{k}, 'data') && size(dadosX{k}.data, 2) >= 21
        M = mean(dadosX{k}.data(:, 2:21)'); % M�dia das colunas 2 a 21
        X(k, :) = M;
    else
        error('O arquivo %s n�o cont�m dados suficientes (pelo menos 21 colunas).', arquivo);
    end
end

% Aplicar a transforma��o log(1/X)
X = log(1/X);

% Extrair r�tulos dos nomes dos arquivos
nomes_arquivos = {asc.name}';
Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);

% Extrair a escala (primeira coluna dos dados)
Scale = dadosX{1}.data(:, 1);

% Excluir arquivos "_modificado.csv"
modificados = dir('*_modificado.csv');
for k = 1:length(modificados)
    delete(modificados(k).name);
end

% Limpar vari�veis desnecess�rias
clear nomes_arquivos asc M dadosX k numfile fid linhas i j novo_arquivo num_virgulas virgula_posicoes posicao modificados ans arquivo;
