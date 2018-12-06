# Start from a core stack version
FROM jupyter/datascience-notebook:14fdfbf9cfc1

# Install Tensorflow
RUN conda install --quiet --yes \
'tensorflow*' \
'keras*' && \
conda clean -tipsy && \
fix-permissions $CONDA_DIR && \
fix-permissions /home/$NB_USER

# Install TextXD requirements that don't already exist in
# jupyter/datascience-notebook
RUN conda install --quiet --yes \
  'requests' \
  'nltk' \
  'lxml' \
  'gensim' && \
  conda clean -tipsy && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

RUN pip install nbgitpuller && \
  jupyter serverextension enable --py nbgitpuller --sys-prefix

RUN pip install youtube-dl && ln -s /opt/conda/bin/youtube-dl /opt/conda/bin/gdrive-dl
RUN python3 -c 'import nltk; nltk.download("popular")'
