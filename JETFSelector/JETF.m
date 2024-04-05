classdef JETF < handle
    %% JETF is the main class to handle requests to the website justETF.com.
    %
    %
    % Author:   Antonino Mazzola
    %
    % Date:     17/03/2024 - First release
    %           22/03/2024 - Code comments
    %
    % Inputs:
    %           Input - nothing required
    %
    % Outputs:
    %           Output - object instance of JETF
    %
    % Example:
    %
    %           jtf = JETF()
    
    %% Main code
    properties
        data
        
        BASE_URL = 'https://www.justetf.com/servlet/etfs-table';
        options = weboptions('RequestMethod', 'post', 'ArrayFormat','json');
        etfsParams = 'groupField=none&productGroup=epg-longOnly';
        
        filters = {
            'assetClass'
            'distributionPolicy'
            'replicationType'
            }
        
        assetClassBase = 'assetClass=class-';
        assetClassOptions = {
            'equity'
            'bonds'
            'preciousMetals'
            'commodities'
            'currency'
            'realEstate'
            'moneyMarket'
            };
        
        distributionPolicyBase = 'distributionPolicy=distributionPolicy-';
        distributionPolicyOptions = {
            'accumulating'
            'distributing'
            };
        
        replicationTypeBase = 'replicationType=replicationType-';
        replicationTypeOptions = {
            'full'
            'sampling'
            'swapBased'
            };
        
        region = ...
            {'','Regions';
            'all','All Regions';
            'Africa','Africa';
            'Asia%2BPacific', 'Asia Pacific';
            'Eastern%2BEurope','Eastern Europe';
            'Emerging%2BMarkets','Emerging Markets';
            'Europe','Europe';
            'Latin%2BAmerica','Latin America';
            'North%2BAmerica','North America';
            'World', 'World'};
        
        country = ...
            {'','Countries';
            'all','All Countries';
            'AU','Australia';
            'AT','Austria';
            'BR','Brazil';
            'CA','Canada';
            'CN','China';
            'FR','France';
            'DE','Germany';
            'IN','India';
            'IT','Italy';
            'JP','Japan';
            'MX','Mexico';
            'NL','Netherlands';
            'KR','Korea';
            'ES','Spain';
            'CH','Switzerland';
            'TW','Taiwan';
            'TR','Turkey';
            'GB','United Kingdom';
            'US','United States'};
        
        listings = ...
            {
            'XMIL', 'Borsa Italiana',           'MI'
            'XLON', 'London Stock Exchange',    'L'
            'XETR', 'XETRA',                    'DE'              
            'XSTU', 'Stuttgard',                'SG'           
            'XPAR', 'Euronext Paris',           'PA'  
            'XMAD', 'Madrid',                   'MA'       
            'XAMS', 'Euronext Amsterdam',       'AS'
            }
        
        fields_to_keep = {
            'name'
            'isin'
            'ticker'
            'distributionPolicy'
            'fundCurrency'
            'yearDividendYield'
            'currentDividendYield'
            'groupValue'
            'groupParam'
            'wkn'
            'ter'
            'replicationMethod'
            'numberOfHoldings'
            'inceptionDate'
            'fundSize'
            'domicileCountry'
            'valorNumber'
            'weekReturnCUR'
            'monthReturnCUR'
            'threeMonthReturnCUR'
            'sixMonthReturnCUR'
            'ytdReturnCUR'
            'yearReturnCUR'
            'threeYearReturnCUR'
            'fiveYearReturnCUR'
            'yearMaxDrawdownCUR'
            'threeYearMaxDrawdownCUR'
            'fiveYearMaxDrawdownCUR'
            'maxDrawdownCUR'
            };
        
    end
    
    methods
        % Class constructor
        function obj = JETF()
            
        end
        
        % query the website
        function make_request(obj, mainFilters, options)
            
            Params = obj.etfsParams;
            if ~isempty(mainFilters)
                for nn = 1:numel(mainFilters(:,1))
                    if any(strcmp(mainFilters{nn,1} , obj.filters))
                        for jj = 1:numel(mainFilters{nn,2})
                            if ~isempty(mainFilters{nn,2}{jj})
                                Params =  [Params '&' obj.([mainFilters{nn,1} 'Base']) mainFilters{nn,2}{jj}];
                            end
                        end
                    end
                end
            end
            
            if ~isempty(options)
                fields = fieldnames(options);
                for jj = 1:numel(fields)
                    theField = fields{jj};
                    if strcmp(theField, 'listings')
                        theField = 'ls';
                    end
                    for nn = 1:numel(options.(fields{jj})(:,1))
                        if ~isempty(options.(fields{jj}){nn,1})
                            Params =  [Params '&' theField '=' options.(fields{jj}){nn,1}];
                        end
                    end
                end
            end
            
            Data = webread(...
                obj.BASE_URL,...
                'draw',1,...
                'start',0,...
                'length',-1,...
                'lang', 'en',...
                'country' ,'IT',...
                'universeType','private',...
                'etfsParams',Params,...
                obj.options);
            
            obj.convert_data(Data.data);
        end
        
        % filter out fields not required
        function convert_data(obj, Data)
            all_fields = fieldnames(Data);
            fields_to_remove = setdiff(all_fields, obj.fields_to_keep);
            obj.data = rmfield(Data, fields_to_remove);
        end
    end
end

