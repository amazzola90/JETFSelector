function out = JETFSelector()
%% JETFSelector is a simple matlab gui to do a screening of ETF/ETC/ETN based on some search filters.
% The tool connects to the justETF.com website and does the query of the
% asset information based on the selection criteria.
%
%
% Author:   Antonino Mazzola
%
% Date:     17/03/2024 - First release
%           18/03/2024 - Code comments and default output bug fix
%           05/04/2024 - Bug fix when selecting assets with different
%                        filter selection
%
% Inputs:
%           Input - nothing required
%
% Outputs:
%           Output - structures with selected assets info
%
% Example:
%
%           out = JETFSelector()

%% Define default output
out = [];

%% instance of JTF class
jtf = JETF();

%% GUI creation
delete(findall(0, 'type', 'figure', 'tag', 'AssetSelector'));

figH = figure(...
    'units'                         , 'pixels', ...
    'busyaction'                    , 'queue', ...
    'color'                         , 'white', ...
    'windowstyle'                   , 'normal',...
    'closerequestfcn'               , @SettingsDialogCloseReqFcn, ...
    'deletefcn'                     , @SettingsDialogDeleteFcn, ...
    'doublebuffer'                  , 'on', ...
    'interruptible'                 , 'on', ...
    'menubar'                       , 'none', ...
    'name'                          , 'JETFSelector', ...
    'numbertitle'                   , 'off', ...
    'resize'                        , 'on', ...
    'tag'                           , 'AssetSelector', ...
    'toolbar'                       , 'none', ...
    'visible'                       , 'off', ...
    'defaulttextfontunits'          , 'pixels', ...
    'defaulttextfontname'           , 'Verdana', ...
    'defaulttextfontsize'           , 12, ...
    'defaultuicontrolfontunits'     , 'pixels', ...
    'defaultuicontrolfontsize'      , 10, ...
    'defaultuicontrolfontname'      , 'Verdana', ...
    'defaultuicontrolinterruptible' , 'off', ...
    'DockControls'                  , 'off');


figH.Position   = [300 150 1200 600];
figH.Visible    = 'on';
jFrame          = get(handle(figH),'javaframe');
drawnow; pause(0.01);
jFrame.fHG2Client.getWindow.setAlwaysOnTop(true);
% % jFrame = getjframe(figH);
% % jFrame.setAlwaysOnTop(true);

% main gui components creation
FontSize = 11;

vBox = uix.VBox( 'Parent', figH, 'Spacing', 2, 'Padding', 5,'BackgroundColor',[1 1 1] );

% Filters section
hRowFilters = uix.HBox( 'Parent', vBox, 'Spacing', 10, 'Padding', 0,'BackgroundColor',[1 1 1] );
vBox1 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hAssetTypeCheck = uicontrol( 'Style','check','Parent', vBox1, 'String','Asset Type','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@AssetTypeCheckCallback);
hAssetTypePopup = uicontrol( 'Style','popup','Parent', vBox1, 'String',JETF().assetClassOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox1, 'Heights', [25 25] );

vBox2 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hPolicyCheck = uicontrol( 'Style','check','Parent', vBox2, 'String','Distribution Policy','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@PolicyCheckCallback);
hPolicyPopup = uicontrol( 'Style','popup','Parent', vBox2, 'String',JETF().distributionPolicyOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox2, 'Heights', [25 25] );

vBox3 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hReplicationCheck = uicontrol( 'Style','check','Parent', vBox3, 'String','Replication Type','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@ReplicationCheckCallback);
hReplicationPopup = uicontrol( 'Style','popup','Parent', vBox3, 'String',JETF().replicationTypeOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox3, 'Heights', [25 25] );

vBox4 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hCountryCheck = uicontrol( 'Style','check','Parent', vBox4, 'String','Country','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@CountryCheckCallback);
hCountryPopup = uicontrol( 'Style','popup','Parent', vBox4, 'String',JETF().country(:,2),'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox4, 'Heights', [25 25] );

vBox5 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hListingsCheck = uicontrol( 'Style','check','Parent', vBox5, 'String','Listing','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@ListingsCheckCallback);
hListingsPopup = uicontrol( 'Style','popup','Parent', vBox5, 'String',JETF().listings(:,2),'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox5, 'Heights', [25 25] );

uix.Empty('Parent',vBox);

hRowApplyFilters = uix.HBox( 'Parent', vBox, 'Spacing', 10, 'Padding', 0,'BackgroundColor',[1 1 1] );
uicontrol( 'Style','push','Parent', hRowApplyFilters, 'String',{'Reset Filters'},'FontSize',FontSize,'Callback',@ResetFilters);
uicontrol( 'Style','push','Parent', hRowApplyFilters, 'String',{'Apply Filters'},'FontSize',FontSize,'Callback',@ApplyFilters);
uix.Empty('Parent',hRowApplyFilters);
set( hRowApplyFilters, 'Widths', [100 100 -1] );

uix.Empty('Parent',vBox);

% Tree and Dual List section
hRow = uix.HBox( 'Parent', vBox, 'Spacing', 5, 'Padding', 0,'BackgroundColor',[1 1 1] );
PanelTree =  uipanel(...
    'units'                     , 'normalized', ...
    'bordertype'                , 'none', ...
    'fontname'                  , 'Verdana', ...
    'fontweight'                , 'normal', ...
    'title'                     , '', ...
    'titleposition'             , 'lefttop', ...
    'backgroundcolor'           , 'white', ...
    'highlightcolor'            , 'white',...
    'foregroundcolor'           , 'white',...
    'parent'                    , hRow, ...
    'tag'                       , 'TreePanel');


% need to define a jScrollPane as container for the jTree
jScroll = javaObjectEDT(javax.swing.JScrollPane);
[~,hScrollContainer] = javacomponent(...
    jScroll,...
    [0 0 1 1],...
    PanelTree);

hScrollContainer.Units      = 'normalized';
hScrollContainer.Position   = [0 0 1 1];

% Definition of dual list object
jListModel  = javaObjectEDT(com.jidesoft.list.DefaultDualListModel());
jList       = handle(javaObjectEDT(com.jidesoft.list.DualList(jListModel)), 'CallbackProperties');
jList.setSelectionMode(jListModel.DISABLE_SELECTION);

% jOrigList = handle(javaObjectEDT(jList.getOriginalList), 'CallbackProperties');
jSelecList = handle(javaObjectEDT(jList.getSelectedList), 'CallbackProperties');

% jOrigList.MouseClickedCallback = @AssetSelectedCallback;
jSelecList.PropertyChangeCallback = @AssetSelectedCallback;


[hList, hListContainer] = javacomponent(jList, [0 0 500 300], hRow);
hList.setBackground(java.awt.Color(1,1,1));
hList.getComponent(0).setBackground(java.awt.Color(1,1,1));
hList.getComponent(1).setBackground(java.awt.Color(1,1,1));
hList.getComponent(2).setBackground(java.awt.Color(1,1,1));
hListContainer.Units = 'norm';
hListContainer.BackgroundColor = 'w';
set(hRow, 'Widths', [200 -1] )

uix.Empty('Parent',vBox);

% adding a search box to filter further with asset name or isin or ticker
SearchRow = uix.Grid('Parent',vBox, 'Spacing', 5, 'Padding', 0, 'BackgroundColor',[1 1 1]);

jSearch = com.mathworks.widgets.SearchTextField('Asset Name');
jSearchPanel = javaObjectEDT(jSearch.getComponent);
jSearchPanel = handle(jSearchPanel, 'CallbackProperties');

jSearchBox = handle(javaObjectEDT(jSearchPanel.getComponent(0)), 'CallbackProperties');
set(jSearchBox, 'ActionPerformedCallback', @PrintCurrentSearch)
set(jSearchBox, 'KeyPressedCallback', @KeyPressedCallback)
jClearButton = handle(javaObjectEDT(jSearchPanel.getComponent(1)), 'CallbackProperties');
set(jClearButton, 'ActionPerformedCallback', @PrintCurrentSearch)

[~, ~] = javacomponent(jSearchPanel, [1 1 1 1], SearchRow);
set(SearchRow, 'Widths', -1, 'Heights', 25);

% final section with cancel and apply button
FifthRow = uix.HBox( 'Parent', vBox, 'Spacing', 5, 'Padding', 0,'BackgroundColor',[1 1 1] );
uix.Empty('Parent',FifthRow);
uicontrol( 'Style','push','Parent', FifthRow, 'String',{'Cancel'},'FontSize',FontSize,'Callback',@SettingsDialogCloseReqFcn);
uicontrol( 'Style','push','Parent', FifthRow, 'String',{'Apply'},'FontSize',FontSize,'Callback',@ApplyCallback);
set( FifthRow, 'Widths', [-1 100 100] );

set( vBox, 'Heights', [50 5 25 5 -1 5 30 30] );

ListOfAssets  = [];
FullETFNames    = [];
FullETFTags     = [];
FullETFIsins    = [];
FullETFTickers  = [];

% str_ticker      = '';
% str_market      = '';

% call to reset filters triggers the query to jtf
ResetFilters();

try
    waitfor(figH);
catch
end

%% assign output and exit

% -- Old code before 04/05/2024
% for zz = 1:numel(ListOfAssets)
%     idxSel = find(strcmp(FullETFNames, ListOfAssets{zz}));
%     idxSel = idxSel(1);
%     out.(FullETFIsins{idxSel}) = jtf.data(idxSel);
%
%     % update ticker based on the stock market selected
%     out.(FullETFIsins{idxSel}).ticker = [out.(FullETFIsins{idxSel}).ticker str_ticker];
%
%     out.(FullETFIsins{idxSel}).market = str_market;
%
% end

%% Support functions

    function ResetFilters(varargin)
        
        % deactivate all filters popups
        hAssetTypeCheck.Value       = 0;
        hPolicyCheck.Value          = 0;
        hReplicationCheck.Value     = 0;
        hCountryCheck.Value         = 0;
        hListingsCheck.Value        = 0;
        
        AssetTypeCheckCallback();
        PolicyCheckCallback();
        ReplicationCheckCallback();
        CountryCheckCallback();
        ListingsCheckCallback();
        
        % reset also the search box
        jSearchBox.setText('');
        
        % call to apply filters
        ApplyFilters();
        
    end
    function ApplyFilters(varargin)
        set(figH,'Pointer','watch');
        drawnow nocallbacks
        pause(0.01)
        
        % call to JTF
        queryJTF();
        
        set(figH,'Pointer','arrow');
        drawnow nocallbacks
        pause(0.01)
    end
    function queryJTF(varargin)
        
        % Build up the filter matrix
        asset_filter = [];
        if hAssetTypeCheck.Value
            asset_filter = {'assetClass',hAssetTypePopup.String(hAssetTypePopup.Value)};
        end
        policy_filter = [];
        if hPolicyCheck.Value
            policy_filter = {'distributionPolicy',hPolicyPopup.String(hPolicyPopup.Value)};
        end
        replication_filter = [];
        if hReplicationCheck.Value
            replication_filter = {'replicationType',hReplicationPopup.String(hReplicationPopup.Value)};
        end
        
        the_filter = [
            asset_filter
            policy_filter
            replication_filter
            ];
        
        options = [];
        if hCountryCheck.Value
            options.country = JETF().country(hCountryPopup.Value,1);
        end
        if hListingsCheck.Value
            options.listings = JETF().listings(hListingsPopup.Value,[1 3]);
        end
        % call to jtf to query justetf.com
        
        jtf.make_request(the_filter,  options);
        
        % process data output
        DataEtf         = jtf.data;
        
        FullETFNames    = {DataEtf(:).name}';
        FullETFIsins    = {DataEtf(:).isin}';
        FullETFTickers  = {DataEtf(:).ticker}';
        
        % first word of etf names is the management company of the fund
        FullETFTags     = strtok(FullETFNames, ' ');
        
        % build tree
        [MainNode, ~]   = BuildTree(FullETFTags);
        jTree           = com.mathworks.mwswing.MJTree(MainNode);
        
        set(jTree, 'MousePressedCallback', @TreeMousePressedFcn);
        
        jScroll.setViewportView(jTree);
        
        % process search box string
        ListOfAssets = GetCurrentTextString(FullETFNames, FullETFIsins, FullETFTickers);
        
        % update dual list
        setListToDualList(ListOfAssets);
        
    end

% Filters callbacks
    function CountryCheckCallback(varargin)
        if hCountryCheck.Value
            hCountryPopup.Enable = 'on';
        else
            hCountryPopup.Enable = 'off';
        end
        %         ApplyFilters();
    end
    function ListingsCheckCallback(varargin)
        if hListingsCheck.Value
            hListingsPopup.Enable = 'on';
        else
            hListingsPopup.Enable = 'off';
        end
        %         ApplyFilters();
    end
    function AssetTypeCheckCallback(varargin)
        if hAssetTypeCheck.Value
            hAssetTypePopup.Enable = 'on';
        else
            hAssetTypePopup.Enable = 'off';
        end
        %         ApplyFilters();
    end
    function PolicyCheckCallback(varargin)
        if hPolicyCheck.Value
            hPolicyPopup.Enable = 'on';
        else
            hPolicyPopup.Enable = 'off';
        end
        %         ApplyFilters();
    end
    function ReplicationCheckCallback(varargin)
        if hReplicationCheck.Value
            hReplicationPopup.Enable = 'on';
        else
            hReplicationPopup.Enable = 'off';
        end
        %         ApplyFilters();
    end
    function KeyPressedCallback(varargin)
        if varargin{2}.getKeyCode == 10 % this is the "enter" key code
            PrintCurrentSearch(varargin{:});
        end
    end

% search box function to process and update the dual list
    function PrintCurrentSearch(varargin)
        ListOfAssets = GetCurrentTextString(FullETFNames, FullETFIsins, FullETFTickers);
        setListToDualList(ListOfAssets);
    end

% function that does the actual search box string processing
    function ListOfAssets_ = GetCurrentTextString(Names, Isins, Tickers, varargin)
        
        CurrentString   = lower(char(jSearchBox.getText));
        
        idxNames        = contains(lower(Names),CurrentString);
        idxIsins        = contains(lower(Isins),CurrentString);
        idxTickers      = contains(lower(Tickers),CurrentString);
        
        % if the user puts the isin or the ticker the tool will find the
        % correspondent asset
        idxs            = idxNames | idxIsins | idxTickers;
        
        ListOfAssets_ = Names;
        if sum(idxs)>0
            ListOfAssets_ = Names(idxs);
        end
        
    end
    function setListToDualList(ListOfAssets)
        ListSelected = hList.getSelectedIndices;
        ListOfSelected = cell(numel(ListSelected), 1);
        for nn = 1:numel(ListSelected)
            ListOfSelected{nn, 1} = hList.getModel.getElementAt(ListSelected(nn));
        end
        hList.getModel.removeAllElements;
        
        listModel = com.jidesoft.list.DefaultDualListModel();
        for kk = 1:numel(ListOfSelected)
            listModel.addElement(ListOfSelected{kk});
        end
        
        listModel.selectAll;
        for kk = 1:numel(ListOfAssets)
            listModel.addElement(ListOfAssets{kk});
        end
        
        hList.setModel(listModel);
    end

% jTree callbacks
    function TreeMousePressedFcn(~,eventData)
        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        try
            node = treePath.getLastPathComponent;
            
            CurrentSelectedPath = node2path(node);
            
            PathParts = strsplit(CurrentSelectedPath,'\');
            if numel(PathParts) >=2
                
                CurrentTag = PathParts{end};
                
                IdxCurrentTag = strcmp(FullETFTags,CurrentTag);
                IdxCurrentTag = sum(IdxCurrentTag,2);
                idxPos = IdxCurrentTag > 0;
                IdxTags = false(size(IdxCurrentTag));
                IdxTags(idxPos) = true;
                
                ListOfAssets_ = FullETFNames(IdxTags);
                ListOfIsins_ = FullETFIsins(IdxTags);
                ListOfTickers_ = FullETFTickers(IdxTags);
                
                ListOfAssets = GetCurrentTextString(ListOfAssets_, ListOfIsins_, ListOfTickers_);
                
                setListToDualList(ListOfAssets)
            else
                return
            end
            
        catch
            
        end
        
    end
    function [path, path1] = node2path(node)
        path  = node.getPath;
        path1 = path;
        p = cell(1, length(path));
        for i = 1:length(path)
            p{i} = char(path(i).getUserObject);
        end
        if length(p) > 1
            path = fullfile(p{:});
        else
            path = p{1};
        end
    end

% Apply button callback
    function ApplyCallback(varargin)
        % -- Old code before 04/05/2024 --
        %         ListOfAssets = cell(hList.getSelectedValues);
        %         if hListingsCheck.Value
        %             str_ticker = ['.' JETF().listings{hListingsPopup.Value,3}];
        %             str_market = JETF().listings{hListingsPopup.Value,2};
        %         end
        
        delete(figH)
    end
    function AssetSelectedCallback(varargin)
        
        try % function is triggered internally from some java properties updates, so skip in that case...
            ListOfAssets = cell(hList.getSelectedValues);
            if hListingsCheck.Value
                str_ticker = ['.' JETF().listings{hListingsPopup.Value,3}];
                str_market = JETF().listings{hListingsPopup.Value,2};
            end
            FullAssetIsinsList = {};
            if ~isempty(out)
                FullAssetIsinsList = fieldnames(out);
            end
            for tt = 1:numel(ListOfAssets)
                idxSel = find(strcmp(FullETFNames, ListOfAssets{tt}));
                if ~isempty(idxSel)
                    idxSel = idxSel(1);
                    
                    theIsin = FullETFIsins{idxSel};
                    
                    if any(strcmp(FullAssetIsinsList, theIsin)) % asset already selected, skip
                        continue
                    end
                    
                    out.(FullETFIsins{idxSel}) = jtf.data(idxSel);
                    
                    % update ticker based on the stock market selected
                    out.(FullETFIsins{idxSel}).ticker = [out.(FullETFIsins{idxSel}).ticker str_ticker];
                    out.(FullETFIsins{idxSel}).market = str_market;
                end
                
            end
            
            if ~isempty(out)% remove assets unselected from dual list
                FullAssetIsinsList = fieldnames(out);
                FullAssetList = cell(1, numel(FullAssetIsinsList));
                for tt = 1:numel(FullAssetIsinsList)
                    FullAssetList{tt} = out.(FullAssetIsinsList{tt}).name;
                end
                [~, idxs] = setdiff(FullAssetList, ListOfAssets); % remove assets unselected from dual list
                AssetsToRemove = FullAssetIsinsList(idxs);
                out = rmfield(out, AssetsToRemove);
            end
        catch
        end
        disp('action performed...')
    end
    function SettingsDialogCloseReqFcn(varargin)
        ListOfAssets    = [];
        out             = [];
        delete(figH)
    end
    function SettingsDialogDeleteFcn(varargin)
        
        set(figH,  'closerequestfcn', '');
        delete(figH);
        
    end
end

function [MainNode, ModelStructure] = BuildTree(FullAssetsTags)

import com.mathworks.mwswing.checkboxtree.*


MainNode = DefaultCheckBoxNode('Asset Company');
ListOfTag = unique(FullAssetsTags);

ModelStructure = [];
for k = 1:length(ListOfTag)
    
    CurrentTag = ListOfTag{k};
    TagNode = DefaultCheckBoxNode(CurrentTag);
    MainNode.add(TagNode);
    
end

end