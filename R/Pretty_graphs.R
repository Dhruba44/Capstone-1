##THIS SECTION NEEDS WORK, BUT IS ARGUABLY NOT IMPORTANT YET.. MOST OF THE CODE IS JUST SHOTGUN STYLE AT THE MOMENT.

###
library(tidyr)
library(tableHTML)
library(flextable)

##import sMAPES and combine
names_list<-c("ARIMA_sMAPES_","HW_ADDI_sMAPES_","HW_MULTI_sMAPES_","MLP_sMAPES_","ARIMA_ALLHW_MLP_mean_sMAPES_",'ARIMA_ALLHW_MLP_median_sMAPES_','ARIMA_MLP_mean_sMAPES_','HWADD_MLP_mean_sMAPES_')
folder_list<-c("sMAPES")

my_sMAPES<-import_multiple_smapes(names_list,folder_list)


##This is only to write smapes to the sMAPE folder...if you need to
# my_forecasts<-read_forecasts(folder = 'MLP_Forecasts',name = "MLP_forecast_combined")
#
# my_sMAPES<-sMAPE_calculate(json_file,my_forecasts)
# my_sMAPES
# write_sMAPES(my_sMAPES,'sMAPES','MLP')

##################################################################################

##This formats everything for the table..This is for the MEAN
all_metrics <- data.frame(Name = character(), Horizon = integer(), Type = character(), Value = numeric())

my_method <- c("ARIMA", "HW Mult", "HW Add","MLP",'ENS 1','ENS 2','ENS 3','ENS 4')
#ENS 1 = All HW, MLP, ARIMA mean
#ENS 2 = All HW, MLP, ARIMA median
#ENS 3 = ARIMA MLP mean
#ENS 4 = HW_Add MLP mean
#
#
sapply(1:length(my_method), function(x) {
  temp <- data.frame(Mean = my_sMAPES[[x]]$Mean, Median = my_sMAPES[[x]]$Median, Horizon = 2:18)
  temp_long <- gather(temp, key = "Type", value = "Value", Mean, Median)
  temp_long$Name <- my_method[x]
  all_metrics <<- rbind(all_metrics, temp_long)
})


temp<-all_metrics%>%pivot_wider(names_from=Name,values_from=Value)
temp_mean<-temp[temp$Type=='Mean',]
temp_mean<-temp_mean[,-2]
temp_mean<-t(temp_mean)
nem<-c('2','3','4','5',"6",'7','8','9','10','11','12','13','14','15','16','17','18')
nem<-as.character(nem)
temp_mean<-as.data.frame(temp_mean)
temp_mean<-round(temp_mean,digits=2)
names(temp_mean)<-nem
temp_mean<-temp_mean[-1,]
temp_mean$Horizon<-row.names(temp_mean)
temp_mean<-temp_mean[,c(18,1:17)]

##Gets minimum values for highlighting
min_vals <- apply(temp_mean[,-1], 2, min)


tableHTML(temp_mean,rownames = FALSE,widths = c(500,rep(100,17)),collapse = 'separate',spacing = '3px',
          border = 0 ,second_headers=list(18,c('Mean sMAPE Values on Horizons 2-18')))%>%
  add_css_conditional_column(conditional = 'min',
                             same_scale=FALSE,
                             css = list('border', '5px solid #CD7F32'),
                             columns =2:(length(temp_mean)))%>%  add_css_row(css = list(c( 'font-size', 'text-align','height'), c( '20px', 'center','50px')))%>%
  add_css_row(css = list('background-color', '#f2f2f2'),
              rows = odd(3:10))%>%
  add_css_column(css=list(c('font-weight','padding-right'),c('bold','20px')),columns = 1)%>%
  #add_css_caption(css =list(c('border-collapse','border-spacing'),c('separate','15px')))%>%
  add_css_header(css = list( c('height','border-bottom','background-color','color','font-size'), c('10px','5px solid steelblue','steelblue','white','30px')),headers = 1:19)



render_tableHTML(table)
#############################################################



tableHTML(temp_mean,rownames = FALSE,widths = c(60,rep(100,17)),
          border = 2 ,second_headers=list(18,c('Mean sMAPE Values on Horizons 2-18')))%>%
  add_css_conditional_column(conditional = 'min',
                             same_scale=FALSE,
                             css = list('border', '5px solid #CD7F32'),
                             columns =2:(length(temp_mean))) %>%
  add_css_row(css = list(c( 'font-size', 'text-align'), c( '35px', 'center')))%>%
  add_css_row(css = list('background-color', '#f2f2f2'),
              rows = odd(3:5))%>%
  # add_css_header(css = list(c('transform', 'height'),
  #                           c('rotate(-25deg)', '50px')),
  #                headers = 2:19)
  add_css_header(css = list( c('height','border-bottom-width'), c('100px','8px')),
                 headers = 2:19)%>%
  add_css_second_header(css=list('height','100px'),second_headers = 1:19)

############################################################################################

temp<-all_metrics%>%pivot_wider(names_from=Name,values_from=Value)
temp_mean<-temp[temp$Type=='Median',]
temp_mean<-temp_mean[,-2]
temp_mean<-t(temp_mean)
nem<-c('2','3','4','5',"6",'7','8','9','10','11','12','13','14','15','16','17','18')
nem<-as.character(nem)
temp_mean<-as.data.frame(temp_mean)
temp_mean<-round(temp_mean,digits=2)
names(temp_mean)<-nem
temp_mean<-temp_mean[-1,]
temp_mean$Horizon<-row.names(temp_mean)
temp_mean<-temp_mean[,c(18,1:17)]


table<-tableHTML(temp_mean,widths = rep(100,18),spacing = '3px',second_headers=list(18,c('Median sMAPE Values on Horizons 2-18')),rownames = FALSE)%>%
  add_css_row(css = list(c( 'font-size', 'text-align'), c( '35px', 'center')))%>%
  add_css_conditional_column(conditional = 'min',
                             same_scale=FALSE,
                             css = list('border', '5px solid #CD7F32'),
                             columns =2:(length(temp_mean)))%>%
  add_css_header(css = list(c('transform', 'height'),
                            c('rotate(-25deg)', '50px')),
                 headers = 2:19) %>%
  add_css_row(css = list('background-color', '#f2f2f2'),
              rows = odd(3:5))
render_tableHTML(table)

###
library(ggplot2)
library(ggthemes)

le_group=interaction(all_metrics$Name[all_metrics$Type=='Mean',],all_metrics$Type[all_metrics$Type=='Mean',])

all_metrics[all_metrics$Type=='Mean',]%>% ggplot(aes(x=Horizon,y=Value,group=interaction(Type,Name),color=interaction(Type,Name)))+geom_line(size=1.2)+
  ylab("sMAPE")+theme_clean()+theme(axis.title = element_text(face="bold"),axis.text = element_text(face="bold"))+
  ggtitle("Horizon vs sMAPE")+theme(plot.title = element_text(hjust=.5))+scale_color_manual(name = "Measure and Model",values=palette)

palette<-c("#00CD66", "#CD3278", "#36648B", "#CDAD00", "#CD7F32", "#BA55D3")
palette<-c("#00CD66", "#CD3278", "#36648B", "#CDAD00", "#CD7F32", "#BA55D3",
                     "#FFA500", "#228B22", "#8B008B", "#FFC0CB", "#00CED1", "#FFD700",
                     "#FF1493", "#008080", "#800080", "#FF4500")

all_metrics[all_metrics$Type=='Mean',]%>% ggplot(aes(x=Horizon,y=Value,color=Name))+geom_line(size=1.2)+
  ylab("sMAPE")+theme_clean()+theme(axis.title = element_text(face="bold"),axis.text = element_text(face="bold"))+
  ggtitle("Horizon vs sMAPE")+theme(plot.title = element_text(hjust=.5))+scale_color_manual(name = "Measure and Model",values=palette)
