TARGET = flp24-log

SOURCES = src/main.pl src/stdin_stdout_utils.pl src/ids.pl src/tower.pl src/bfs.pl

all: $(TARGET)

$(TARGET): $(SOURCES)
	swipl -q -g start -o $(TARGET) -c src/main.pl

clean:
	rm -f $(TARGET)