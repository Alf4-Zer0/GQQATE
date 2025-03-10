% -------------------------------------------------------------------------
% Função:
% importxrf
% -------------------------------------------------------------------------
% Uso:
% Esta função importa dados de arquivos .txt de análises Raman na pasta atual, realiza o processamento necessário e 
% os adiciona ao workspace do MATLAB. 
% -------------------------------------------------------------------------
% A função executa as seguintes etapas:
% 1. Identifica todos os arquivos .txt na pasta atual.
% 2. Inicializa a matriz de saída Data.
% 3. Abre o arquivo e lê seu conteúdo para cada arquivo .txt:
% 4. Importa um vetor com os rótulos das amostras.
% 5. Adiciona as variáveis Data e Label ao workspace base do MATLAB.
% -------------------------------------------------------------------------
% Escrito por:
% Hélio Milito Martins de Amorim Neto
% Departamento de Química, Instituto de Ciências Exatas
% Universidade Federal de Minas Gerais
% Janeiro 2025
% -------------------------------------------------------------------------

% Obter lista de arquivos .txt na pasta atual
asc = dir('*.txt');

% Inicializar a matriz Data
Data = [];

% Loop sobre todos os arquivos .txt encontrados
for i = 1:length(asc)
    % Nome do arquivo atual
    nomeArquivo = asc(i).name;
    
    % Importar os dados do arquivo (assumindo que os dados são numéricos)
    % Aqui, utilizamos o comando 'load' para carregar dados numéricos
    dadosArquivo = load(nomeArquivo);
    
    % Verificar se os dados do arquivo são uma coluna ou uma matriz
    if iscolumn(dadosArquivo)
        % Se for uma coluna, só adicionar na matriz Data
        Data = [Data, dadosArquivo];
    elseif ismatrix(dadosArquivo)
        % Se for uma matriz, concatene coluna por coluna
        Data = [Data, dadosArquivo];
    end
end

% Importa o vetor com os rótulos das amostras
nomes_arquivos = {asc.name}';
Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);
clear asc dadosArquivo i nomeArquivo nomes_arquivos