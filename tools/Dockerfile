FROM pandoc/latex:latest

# Workdir inside container
WORKDIR /work

# Copy repository into container workdir
COPY . /work

# Build the manual to PDF using xelatex
RUN pandoc MANUAL.md -o MANUAL.pdf --pdf-engine=xelatex --toc

# Output: /work/MANUAL.pdf
CMD ["/bin/bash"]
