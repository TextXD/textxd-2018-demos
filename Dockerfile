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

USER root

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		libapparmor1 \
		libedit2 \
		lsb-release \
		;

# You can use rsession from rstudio's desktop package as well.
ARG RSTUDIO_VERSION
RUN RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
    && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
    && echo $RSTUDIO_VERSION \
    && wget -q http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
    && dpkg -i rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
    && rm rstudio-server-*-amd64.deb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN pip install git+https://github.com/jupyterhub/nbserverproxy.git
RUN jupyter serverextension enable --sys-prefix --py nbserverproxy

RUN pip install git+https://github.com/jupyterhub/nbrsessionproxy.git
RUN jupyter serverextension enable --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension install    --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension enable     --sys-prefix --py nbrsessionproxy

# The desktop package uses /usr/lib/rstudio/bin
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"
