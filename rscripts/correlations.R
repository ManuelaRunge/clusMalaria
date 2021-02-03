
library(corrplot)


ggplot(data=mydata_scaled,aes(x=PfTSI,y=PfPR.2015 ))+
  geom_point()+  geom_smooth(method='lm',col='black',se=FALSE) + theme_minimal_grid()+
  labs(y='PfPR\n(scaled)', x='Pf TSI\n(scaled)')

corTable <- round(cor(mydata_scaled), 2)
corTable

pdf(file = file.path("fig", "p_corr.pdf"), width = 10, height = 10)
corrplot(corTable, type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)
dev.off()

png(file = file.path("fig", "p_corr.png"))
corrplot(corTable, type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)
dev.off()
