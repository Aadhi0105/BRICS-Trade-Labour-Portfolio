"""Refresh figure presentation from committed snapshots; never write empirical data.

Run from any directory with the repository's plotting dependencies installed.
The original specifications are replayed only for the existing Project 1 charts;
rounded coefficients/SEs are checked against the published values. No new
specifications, classification changes, NLP fitting or source collection runs.
"""
from pathlib import Path
import contextlib
import hashlib
import json
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import geopandas as gpd
import seaborn as sns

ROOT = Path(__file__).resolve().parents[1]
plt.show = lambda: None

def data_hashes():
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for project in ROOT.glob('0*') for p in (project / 'data').rglob('*')
            if p.is_file() and p.suffix.lower() in {'.csv','.rds','.gpkg','.dta','.geojson'}}

@contextlib.contextmanager
def cwd(path):
    before = Path.cwd()
    os.chdir(path)
    try: yield
    finally: os.chdir(before)

def cells(path):
    return json.loads(path.read_text())['cells']

def run(path, indices, env=None):
    env = {} if env is None else env
    with cwd(path.parent):
        source = cells(path)
        for i in indices:
            assert source[i]['cell_type'] == 'code'
            print(f'Render {path.name} cell {i}', flush=True)
            exec(compile(''.join(source[i]['source']), f'{path.name}:{i}', 'exec'), env)
    return env

def main():
    before = data_hashes()
    p1 = ROOT / '01_china_shock_emerging_markets/notebooks'
    # Existing descriptive figures; skip summary CSV export and geographic map.
    # The map needs uncommitted SHRUG location keys; retain its historical export.
    run(p1/'notebook_02_descriptive_analysis.ipynb', [1,2,3,11,12,14,17])
    reg = p1/'notebook_03_regression_analysis.ipynb'
    env = run(reg, [1,2,4,6,10,12])
    assert abs(env['inst_coef']-.125) < .001
    assert abs(env['inst_se']-.017) < .001
    assert abs(env['inst_t']-7.32) < .02
    assert abs(env['partial_r2']-.360) < .002
    for label, target, se in [
        ('outside-NCO-6/9 employment share',.051,.056),
        ('Log weekly wage (rural)',-.220,.168),
        ('Middle-skill share',.023,.055)]:
        result=env['results_iv'][label]
        assert abs(result.params['import_penetration']-target)<.001
        assert abs(result.std_errors['import_penetration']-se)<.001
    run(reg,[7],env)
    # Replay only the plot block, not additional models or table exports.
    code=''.join(cells(reg)[20]['source']).split('# ── Coefficient plot')[1]
    exec(compile('# Coefficient plot'+code, str(reg), 'exec'),env)
    plt.close('all')
    p6=ROOT/'06_trade_exposure_maps/notebooks'
    # All these cells only read saved panels and render figures.
    run(p6/'notebook_2_structural_change.ipynb',[1,4,5,8,11])
    infra=p6/'notebook_3_trade_exposure.ipynb'
    env=run(infra,[1,3])
    env['panel']=gpd.read_file(ROOT/'06_trade_exposure_maps/data/processed/districts_full_panel.gpkg')
    env['sez_gdf']=gpd.read_file(ROOT/'06_trade_exposure_maps/data/raw/infrastructure/major_sezs.geojson')
    run(infra,[22,24,26,29],env)
    pub=p6/'notebook_4_publication_maps.ipynb'
    run(pub,[i for i,c in enumerate(cells(pub)) if c['cell_type']=='code'])
    # Exploratory 2013 map from saved panel rather than rerunning acquisition.
    acq=p6/'notebook_1_data_acquisition.ipynb'
    env=run(acq,[1])
    env['panel']=gpd.read_file(ROOT/'06_trade_exposure_maps/data/processed/districts_structural_change.gpkg')
    plot_idx=next(i for i,c in enumerate(cells(acq)) if c['cell_type']=='code' and 'stage5_nonfarm_share_2013.png' in ''.join(c['source']))
    run(acq,[plot_idx],env)
    plt.close('all')
    # Saved LM scores and saved topic assignments; no NLP models rerun.
    p5=ROOT/'05_monetary_policy_sentiment'
    with cwd(p5):
        df=pd.read_csv('data/brics_mpc_final.csv',parse_dates=['date'])
        env={'df':df,'pd':pd,'np':np,'plt':plt,'sns':sns}
        run(p5/'notebook_2_sentiment.ipynb',[15],env)
        run(p5/'notebook_3_lda.ipynb',[18,21],env)
        # The 40 document-level predictions were not saved in a data file.
        # Plot the existing published count summary without rescoring or
        # reconstructing individual predictions from the old raster.
        counts=pd.DataFrame({'Negative':[6,1,2,9], 'Neutral':[2,5,2,0],
                             'Positive':[2,4,6,1]}, index=['CBR','PBOC','RBI','SARB'])
        fig,ax=plt.subplots(figsize=(10,5.6))
        counts.plot.bar(stacked=True,ax=ax,color=['#c95c54','#aab3bb','#4d9a78'],rot=0,width=.6)
        ax.set(title='FinBERT label counts in the 40-document stratified sample',
               ylabel='Documents',xlabel='Central bank',ylim=(0,12))
        for container in ax.containers:
            ax.bar_label(container, labels=[str(int(v)) if v else '' for v in container.datavalues],label_type='center',fontsize=11)
        ax.legend(ncols=3,frameon=False,loc='upper center')
        ax.spines[['top','right']].set_visible(False)
        ax.set_yticks(range(0,11,2))
        fig.text(.5,.015,'10 documents per bank • first 400 words, tokenizer cap 512 tokens\n'
                 'Published sample comparison with LM: Spearman r = 0.441, p = 0.004; not full-corpus validation.',ha='center',fontsize=9)
        fig.tight_layout(rect=[0,.10,1,1]);fig.savefig('data/lm_vs_finbert.png',dpi=180,bbox_inches='tight');plt.close(fig)
    assert data_hashes()==before, 'Empirical inputs changed during presentation refresh'
    print('All empirical data hashes unchanged.',flush=True)

if __name__=='__main__':main()
