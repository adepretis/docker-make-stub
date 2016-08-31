# Makefile

Die aktuelle Evolutionsstufe des Makefiles (Stand 25.08.2016) generiert die Übersicht der Variablen und der Make-Targets automatisch und in Bunt. Im Falle vom ELK-Stack wird dafür einiges aus der ```25th-floor.mk``` reused, um Code-Redundanzen zwischen den gebündelten Dockerfiles (e.g. ```logstash-indexer```) zu vermeiden.

Das ```25th-floor.mk``` am besten via https://raw.githubusercontent.com/25th-floor/make-common/master/25th-floor.mk herunterladen.

## Target-Beschreibungen

Diese werden aus dem String ```##@Category Description``` neben jedem Target extrahiert (leider keine Interpolation möglich). Beispiel:
```
Makefile
.PHONY: target
target: ##@Other Show this help.
```

Die Ausgabe erfolgt in der ```25th-floor.mk``` im ```help``` Target. Selbiges Target ist eine explizite/double-colon Rule und kann im eigentlichen ```Makefile``` erweitert werden (beide Targets werden ausgeführt:
```
.PHONY: help
help::
    @echo "One more thing ..."
```

## Variablen

Variablen die mittels ```defw``` zugewiesen werden, erhalten eine Ausgabe im ```help``` Target. Leider kann hier nicht mit ```.VARIABLES``` (wie ursprünglich gedacht) gearbeitet werden, da Variablen die via z.B. ```make FOO=bar test``` übergeben werden, nicht mehr erkannt werden können - ```FOO``` ist damit bereits vor dem erstmaligen Speichern des States definiert.

Die Ausgabe im ```help``` Target erfolgt in der Reihenfolge des ```call```-Statements.
```
# Define variables, export them and include them usage-documentation
$(eval $(call defw,RANCHER_ACCESS_KEY,XXXX))
$(eval $(call defw,RANCHER_SECRET_KEY,XXXX))
$(eval $(call defw,RANCHER_URL,XXXX))
$(eval $(call defw,RANCHER_STACK_NAME,XXXX))
```

Die Ausgabe erfolgt in der ```25th-floor.mk``` im ```help``` Target.

TODO: Kategorisierung von Variablen evtl. möglich? (vgl. ```@Category``` beim Target).

## 25th-floor.mk

Dieses sollte im Makefile ganz oben inkludiert werden
```
ifneq ("$(wildcard 25th-floor.mk)","")
    include 25th-floor.mk
endif
```

und liefert folgendes mit:

 * setzt das ```.DEFAULT_GOAL``` auf ```help``` (Default Target)
 * definiert ```HELP_FUN``` (Schwartzscher Transform, s. https://gist.github.com/prwhite/8168133#gistcomment-1727513) für die Darstellung in der Usage
 * definiert ```defw``` - welches wiederum eine Variable setzt, diese exportiert und dem String custom_vars appended
 * definiert die explizite Double-Colon Rule ```help::```, die ```custom_vars``` und ```HELP_FUN``` verwendet um eine schöne Usage zu generieren
  * kann im eigentlichen Makefile mit einem eigenen Double-Colon Target ```help::``` erweitert werden
 * definiert diverse Color Codes
