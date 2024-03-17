function out = JETFSelector()

jtf = JustETF();

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

figH.Position = [300 150 1200 600];
figH.Visible = 'on';

FontSize = 11;

vBox = uix.VBox( 'Parent', figH, 'Spacing', 2, 'Padding', 5,'BackgroundColor',[1 1 1] );

hRowFilters = uix.HBox( 'Parent', vBox, 'Spacing', 10, 'Padding', 0,'BackgroundColor',[1 1 1] );
vBox1 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hAssetTypeCheck = uicontrol( 'Style','check','Parent', vBox1, 'String','Asset Type','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@AssetTypeCheckCallback);
hAssetTypePopup = uicontrol( 'Style','popup','Parent', vBox1, 'String',JustETF().assetClassOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox1, 'Heights', [25 25] );

vBox2 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hPolicyCheck = uicontrol( 'Style','check','Parent', vBox2, 'String','Distribution Policy','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@PolicyCheckCallback);
hPolicyPopup = uicontrol( 'Style','popup','Parent', vBox2, 'String',JustETF().distributionPolicyOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox2, 'Heights', [25 25] );

vBox3 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hReplicationCheck = uicontrol( 'Style','check','Parent', vBox3, 'String','Replication Type','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@ReplicationCheckCallback);
hReplicationPopup = uicontrol( 'Style','popup','Parent', vBox3, 'String',JustETF().replicationTypeOptions,'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox3, 'Heights', [25 25] );

vBox4 =  uix.VBox( 'Parent', hRowFilters, 'Spacing', 2, 'Padding', 0,'BackgroundColor',[1 1 1] );
hCountryCheck = uicontrol( 'Style','check','Parent', vBox4, 'String','Country','FontSize',FontSize,'BackgroundColor',[1 1 1],'Callback',@CountryCheckCallback);
hCountryPopup = uicontrol( 'Style','popup','Parent', vBox4, 'String',JustETF().country(:,2),'FontSize',FontSize,'Callback','','BackgroundColor',[1 1 1]);
set( vBox4, 'Heights', [25 25] );

uix.Empty('Parent',vBox);

hRowApplyFilters = uix.HBox( 'Parent', vBox, 'Spacing', 10, 'Padding', 0,'BackgroundColor',[1 1 1] );
uicontrol( 'Style','push','Parent', hRowApplyFilters, 'String',{'Reset Filters'},'FontSize',FontSize,'Callback',@ResetFilters);
uicontrol( 'Style','push','Parent', hRowApplyFilters, 'String',{'Apply Filters'},'FontSize',FontSize,'Callback',@ApplyFilters);
uix.Empty('Parent',hRowApplyFilters);
set( hRowApplyFilters, 'Widths', [100 100 -1] );

uix.Empty('Parent',vBox);

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


jScroll = javaObjectEDT(javax.swing.JScrollPane);
[~,hScrollContainer] = javacomponent(...
    jScroll,...
    [0 0 1 1],...
    PanelTree);

hScrollContainer.Units      = 'normalized';
hScrollContainer.Position   = [0 0 1 1];

jListModel  = javaObjectEDT(com.jidesoft.list.DefaultDualListModel());
jList       = handle(javaObjectEDT(com.jidesoft.list.DualList(jListModel)), 'CallbackProperties');
jList.setSelectionMode(jListModel.DISABLE_SELECTION);

[hList, hListContainer] = javacomponent(jList, [0 0 500 300], hRow);
hList.setBackground(java.awt.Color(1,1,1));
hList.getComponent(0).setBackground(java.awt.Color(1,1,1));
hList.getComponent(1).setBackground(java.awt.Color(1,1,1));
hList.getComponent(2).setBackground(java.awt.Color(1,1,1));
hListContainer.Units = 'norm';
hListContainer.BackgroundColor = 'w';
set(hRow, 'Widths', [200 -1] )

uix.Empty('Parent',vBox);

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

ResetFilters();

try
    waitfor(figH);
catch
end


for zz = 1:numel(ListOfAssets)
    idxSel = strcmp(FullETFNames, ListOfAssets{zz});
    out.(FullETFIsins{idxSel}) = jtf.data(idxSel);
end

    function ResetFilters(varargin)
        hAssetTypeCheck.Value       = 0;
        hPolicyCheck.Value          = 0;
        hReplicationCheck.Value     = 0;
        hCountryCheck.Value         = 0;
        
        AssetTypeCheckCallback();
        PolicyCheckCallback();
        ReplicationCheckCallback();
        CountryCheckCallback();
        
        jSearchBox.setText('');
        
        ApplyFilters();
        
    end
    function ApplyFilters(varargin)
        set(figH,'Pointer','watch');
        drawnow nocallbacks
        pause(0.01)
        
        queryJTF();
        
        set(figH,'Pointer','arrow');
        drawnow nocallbacks
        pause(0.01)
    end
    function queryJTF(varargin)
        
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
            options.country = JustETF().country(hCountryPopup.Value,1);
        end
        
        jtf.make_request(the_filter,  options);
        
        DataEtf         = jtf.data;
        
        FullETFNames    = {DataEtf(:).name}';
        FullETFIsins    = {DataEtf(:).isin}';
        FullETFTickers  = {DataEtf(:).ticker}';
        
        FullETFTags     = strtok(FullETFNames, ' ');
        
        
        [MainNode, ~]   = BuildTree(FullETFTags);
        jTree           = com.mathworks.mwswing.MJTree(MainNode);
        
        set(jTree, 'MousePressedCallback', @TreeMousePressedFcn);
        
        jScroll.setViewportView(jTree);
        
        ListOfAssets = GetCurrentTextString(FullETFNames, FullETFIsins, FullETFTickers);
        
        setListToDualList(ListOfAssets);
        
    end
    function CountryCheckCallback(varargin)
        if hCountryCheck.Value
            hCountryPopup.Enable = 'on';
        else
            hCountryPopup.Enable = 'off';
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
        if varargin{2}.getKeyCode == 10
            PrintCurrentSearch(varargin{:});
        end
    end
    function PrintCurrentSearch(varargin)
        ListOfAssets = GetCurrentTextString(FullETFNames, FullETFIsins, FullETFTickers);
        setListToDualList(ListOfAssets);
    end
    function ListOfAssets_ = GetCurrentTextString(Names, Isins, Tickers, varargin)
        
        CurrentString   = lower(char(jSearchBox.getText));
        
        idxNames        = contains(lower(Names),CurrentString);
        idxIsins        = contains(lower(Isins),CurrentString);
        idxTickers      = contains(lower(Tickers),CurrentString);
        
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


    function ApplyCallback(varargin)
        ListOfAssets = cell(hList.getSelectedValues);
        delete(figH)
    end
    function SettingsDialogCloseReqFcn(varargin)
        ListOfAssets = [];
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