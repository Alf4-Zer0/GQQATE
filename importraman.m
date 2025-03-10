% -------------------------------------------------------------------------
% Função:
% importraman
% -------------------------------------------------------------------------
% Uso:
% Esta função importa dados de arquivos .csv de análises Raman na pasta atual, realiza o processamento necessário e 
% os adiciona ao workspace do MATLAB. 
% -------------------------------------------------------------------------
% A função executa as seguintes etapas:
% 1. Identifica todos os arquivos .csv na pasta atual.
% 2. Inicializa as matrizes de saída Scale e Data.
% 3. Abre o arquivo e lê seu conteúdo para cada arquivo .csv:
% 4. Importa um vetor com os rótulos das amostras.
% 5. Adiciona as variáveis Scale, Data e Label ao workspace base do MATLAB.
% -------------------------------------------------------------------------
% Escrito por:
% Hélio Milito Martins de Amorim Neto
% Departamento de Química, Instituto de Ciências Exatas
% Universidade Federal de Minas Gerais
% Janeiro 2025
% -------------------------------------------------------------------------

% Obtem a lista de arquivos CSV na pasta atual
asc = dir('*.csv');

% Verifica se ha¡ arquivos CSV na pasta
if isempty(asc)
    error('Nenhum arquivo CSV encontrado na pasta atual.');
end

% Inicializa uma celula para armazenar colunas de dados
Data = {};

% Inicializa a variavel Scale
Scale = [];

% Loop sobre cada arquivo CSV encontrado
for k = 1:length(asc)
    nome_arquivo = asc(k).name;

    % Abre o arquivo ignorando as 30 primeiras linhas
    fid = fopen(nome_arquivo, 'r');
    if fid == -1
        warning('Nao foi possivel abrir o arquivo: %s', nome_arquivo);
        continue;
    end

    % Ignora as primeiras 30 linhas
    for i = 1:30
        if feof(fid)
            warning('Arquivo %s possui menos de 30 linhas e foi ignorado.', nome_arquivo);
            fclose(fid);
            continue;
        end
        fgetl(fid);
    end

    % Le o restante do conteudo do arquivo
    conteudo = fread(fid, '*char')';
    fclose(fid);

    % Substitui virgulas por pontos
    conteudo_corrigido = strrep(conteudo, ',', '.');

    % Salva temporariamente o arquivo corrigido
    nome_temp = ['corrigido_', nome_arquivo];
    fid = fopen(nome_temp, 'w');
    if fid == -1
        warning('Nao foi possivel criar o arquivo temporario: %s', nome_temp);
        continue;
    end
    fwrite(fid, conteudo_corrigido);
    fclose(fid);
    
    % Abre novamente para leitura dos dados
    fid = fopen(nome_temp, 'r');
    if fid == -1
        warning('Nao foi possivel reabrir o arquivo corrigido: %s', nome_temp);
        continue;
    end

    % Le a primeira linha para detectar delimitador automaticamente
    primeira_linha = fgetl(fid);
    fclose(fid);

    if isempty(primeira_linha)
        warning('Arquivo vazio apos remocao de linhas: %s', nome_temp);
        continue;
    end

    % Substitui contains() por strfind() para MATLAB 2010
    if ~isempty(strfind(primeira_linha, ';'))
        delimitador = ';';
    else
        delimitador = ',';
    end

    % Reabre o arquivo para leitura dos dados
    fid = fopen(nome_temp, 'r');
    if fid == -1
        warning('Nao foi possivel abrir o arquivo corrigido: %s', nome_temp);
        continue;
    end

    % Le os dados como string para evitar problemas com colunas variaveis
    dados_raw = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);

    % Processa cada linha e converte para matriz numerica
    num_linhas = length(dados_raw{1});
    dados_coluna = [];

    for i = 1:num_linhas
        linha = str2num(strrep(dados_raw{1}{i}, delimitador, ' ')); %#ok<ST2NM>
        if ~isempty(linha) && length(linha) >= 2  % Verifica se ha pelo menos 2 colunas
            dados_coluna = [dados_coluna; linha(2)]; %#ok<AGROW> % Pega apenas a segunda coluna
        end
    end

    % Verifica se ha dados validos na segunda coluna
    if isempty(dados_coluna)
        warning('Erro ao processar os dados da segunda coluna no arquivo: %s', nome_temp);
        continue;
    end

    % Armazena os dados da segunda coluna em uma nova celula
    Data{end + 1} = dados_coluna; %#ok<AGROW>

    % Se for o primeiro arquivo, extrai a primeira coluna como Scale
    if k == 1
        for i = 1:num_linhas
            linha = str2num(strrep(dados_raw{1}{i}, delimitador, ' ')); %#ok<ST2NM>
            if ~isempty(linha) && length(linha) >= 1  % Verifica se ha pelo menos 1 coluna
                Scale = [Scale; linha(1)]; %#ok<AGROW> % Pega apenas a primeira coluna
            end
        end
    end

    % Remove o arquivo temporario
    delete(nome_temp);
end

% Converte a celula para matriz, preenchendo com NaN onde necessario
max_linhas = max(cellfun(@length, Data));
Data_matrix = NaN(max_linhas, length(Data));

for i = 1:length(Data)
    Data_matrix(1:length(Data{i}), i) = Data{i};
end

% Retorna a matriz final
Data = Data_matrix';

% Importa o vetor com os rotulos das amostras
nomes_arquivos = {asc.name}';
Label = cellfun(@(x) strtok(x, '.'), nomes_arquivos, 'UniformOutput', false);

clear Data_matrix ans asc conteudo conteudo_corrigido dados_coluna dados_raw delimitador fid i k linha max_linhas nome_arquivo nome_temp num_linhas primeira_linha nomes_arquivos;