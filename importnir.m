% -------------------------------------------------------------------------
% Função:
% importnir
% -------------------------------------------------------------------------
% Uso:
% Esta função importa dados de arquivos .csv de análises NIR na pasta atual, realiza o processamento necessário e 
% os adiciona ao workspace do MATLAB. 
% -------------------------------------------------------------------------
% A função executa as seguintes etapas:
% 1. Identifica todos os arquivos .csv na pasta atual.
% 2. Inicializa as matrizes de saída Scale e Data.
% 3. Para cada arquivo .csv:
%    a. Abre o arquivo e lê seu conteúdo.
%    b. Verifica se os decimas estão separados por ponto.
%    c. Caso os decimais estejam separados por vírgula substitui por ponto.
%    d. Realiza a conversão logaritmica dos espectros.
%    e. Adiciona os dados processados à matriz X.
% 4. Importa um vetor com os rótulos das amostras.
% 5. Adiciona as variáveis Scale, X e Label ao workspace base do MATLAB.
% -------------------------------------------------------------------------
% Escrito por:
% Hélio Milito Martins de Amorim Neto
% Departamento de Química, Instituto de Ciências Exatas
% Universidade Federal de Minas Gerais
% Janeiro 2025
% -------------------------------------------------------------------------

% 1º: Listar todos os arquivos CSV na pasta atual
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
        error('Não foi possível abrir o arquivo: %s', arquivo);
    end
    
    % Ler todas as linhas do arquivo
    linhas = textscan(fid, '%s', 'Delimiter', '\n');
    linhas = linhas{1};
    fclose(fid);
    
    % Verificar o número de vírgulas na segunda linha (ignorando o cabeçalho)
    num_virgulas = length(strfind(linhas{2}, ','));
    
    % Se houver 41 vírgulas, substituir as vírgulas nas posições ímpares por pontos
    if num_virgulas == 41
        for i = 2:length(linhas) % Começar da segunda linha (ignorar cabeçalho)
            % Encontrar as posições de todas as vírgulas na linha
            virgula_posicoes = strfind(linhas{i}, ',');
            
            % Substituir vírgulas nas posições ímpares por pontos
            for j = 1:2:length(virgula_posicoes)
                posicao = virgula_posicoes(j); % Posição da vírgula a ser substituída
                linhas{i}(posicao) = '.'; % Substituir vírgula por ponto
            end
        end
        
        % Salvar o arquivo modificado
        novo_arquivo = strrep(arquivo, '.csv', '_modificado.csv');
        fid = fopen(novo_arquivo, 'w');
        if fid == -1
            error('Não foi possível criar o arquivo modificado: %s', novo_arquivo);
        end
        
        for i = 1:length(linhas)
            fprintf(fid, '%s\n', linhas{i});
        end
        fclose(fid);
        
        % Atualizar o nome do arquivo para o arquivo modificado
        arquivo = novo_arquivo;
    elseif num_virgulas ~= 20
        % Se o número de vírgulas não for 20 nem 41, exibir um aviso
        warning('O arquivo %s tem %d vírgulas. Nenhuma ação foi tomada.', arquivo, num_virgulas);
    end
    
    % 4º: Aplicar a rotina de processamento dos dados
    dadosX{k} = importdata(arquivo);
    
    % Verificar se os dados foram importados corretamente e têm colunas suficientes
    if isfield(dadosX{k}, 'data') && size(dadosX{k}.data, 2) >= 21
        M = mean(dadosX{k}.data(:, 2:21)'); % Média das colunas 2 a 21
        X(k, :) = M;
    else
        error('O arquivo %s não contém dados suficientes (pelo menos 21 colunas).', arquivo);
    end
end

% Aplicar a transformação log(1/X)
X = log(1/X);

% Extrair rótulos dos nomes dos arquivos
nomes_arquivos = {asc.name}';
Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);

% Extrair a escala (primeira coluna dos dados)
Scale = dadosX{1}.data(:, 1);

% Excluir arquivos "_modificado.csv"
modificados = dir('*_modificado.csv');
for k = 1:length(modificados)
    delete(modificados(k).name);
end

% Limpar variáveis desnecessárias
clear nomes_arquivos asc M dadosX k numfile fid linhas i j novo_arquivo num_virgulas virgula_posicoes posicao modificados ans arquivo;
