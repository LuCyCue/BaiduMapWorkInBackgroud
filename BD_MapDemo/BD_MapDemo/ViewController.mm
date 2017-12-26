//
//  ViewController.m
//  BD_MapDemo
//
//  Created by mac on 2017/12/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "BDMapKit.h"
#import "CCShowMessage.h"

typedef enum {
    LocationRecordStatePending,    //等待状态，不进行记录
    LocationRecordStateStart,      //开始记录
    LocationRecordStateRecording,  //记录中
    LocationRecordStateEnd,        //结束记录
}LocationRecordState;

@interface ViewController ()<BMKLocationServiceDelegate,BMKMapViewDelegate>

/**地图*/
@property (nonatomic, strong)   BMKMapView  *mapView;
/**定位服务*/
@property (nonatomic, strong)   BMKLocationService *localService;
/**是否设置地图显示范围*/
@property (nonatomic, assign)   BOOL  isSetMapRegion;
/**坐标点记录 */
@property (nonatomic, strong)   NSMutableArray  *ArrayMLocaltions;
/**位置记录状态*/
@property (nonatomic, assign)   LocationRecordState  recordState;
/** 记录上一次的位置 */
@property (nonatomic, strong) CLLocation *preLocation;
/** 起点 */
@property (nonatomic, strong) BMKPointAnnotation *startPoint;
/** 终点 */
@property (nonatomic, strong) BMKPointAnnotation *endPoint;
/** 轨迹线 */
@property (nonatomic, strong) BMKPolyline *polyLine;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpLocalService];
    [self setUpMapView];
    [self initUserData];
    [self setUpNavBar];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = self; // 不用时，置nil
}

#pragma mark --初始化
- (void)setUpMapView
{
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.view = _mapView;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = NO;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    displayParam.locationViewImgName = @"walk";
    [self.mapView updateLocationViewWithParam:displayParam];
}
- (void)setUpLocalService
{
    _localService = [[BMKLocationService alloc]init];
    _localService.delegate = self;
    //启动LocationService
    _localService.pausesLocationUpdatesAutomatically = NO;
    _localService.allowsBackgroundLocationUpdates = YES;
    //更新定位最低距离
    //_localService.distanceFilter = 5.0;
    //开启定位
    //[_localService startUserLocationService];
}
- (void)initUserData{
    _isSetMapRegion = NO;
    _recordState = LocationRecordStatePending;
}

- (void)setUpNavBar
{
    self.title = @"LocationRecord";
    
    // 导航栏左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Start"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(startRecord)];
    // 导航栏右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Stop"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(stopRecord)];
}
#pragma mark --Actions

- (void)startRecord{
    //清除地图上的轨迹线和相关数据
    if (_recordState == LocationRecordStatePending) {
        [CCShowMessage showMessage:@"开始记录行动轨迹" inViewController:self];
        [self cleanPolyLine];
        _recordState = LocationRecordStateStart;
        [_localService startUserLocationService];
    }
}
- (void)stopRecord{
    
    if(_recordState == LocationRecordStateRecording || _recordState == LocationRecordStateStart){
        [CCShowMessage showMessage:@"结束记录行动轨迹" inViewController:self];
        _recordState = LocationRecordStateEnd;
        self.endPoint = [self creatPointWithLocaiton:self.preLocation title:@"终点"];
    }
}


#pragma mark --BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
   [self.mapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    BMK_LOG(@"Update userLocation");
    if (!_isSetMapRegion) {
        _isSetMapRegion = YES;
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.localService.userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    [self.mapView updateLocationData:userLocation];
    [self recordLocation:userLocation];
}



#pragma mark - BMKMapViewDelegate

/**
 *  根据overlay生成对应的View
 *  @param mapView 地图View
 *  @param overlay 指定的overlay
 *  @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}

/**
 *  只有在添加大头针的时候会调用，直接在viewDidload中不会调用
 *  根据anntation生成对应的View
 *  @param mapView 地图View
 *  @param annotation 指定的标注
 *  @return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        if(self.startPoint){ // 有起点旗帜代表应该放置终点旗帜（程序一个循环只放两张旗帜：起点与终点）
            annotationView.pinColor = BMKPinAnnotationColorRed; // 替换资源包内的图片
        }else { // 没有起点旗帜，应放置起点旗帜
            annotationView.pinColor = BMKPinAnnotationColorGreen;
        }
        // 从天上掉下效果
        annotationView.animatesDrop = YES;
        // 不可拖拽
        annotationView.draggable = NO;
        
        return annotationView;
    }
    return nil;
}


#pragma mark --custom Method
- (void)recordLocation:(BMKUserLocation *)userLocation
{
    if (_recordState == LocationRecordStatePending) {
        return;
    }else if(_recordState == LocationRecordStateStart){
        _recordState = LocationRecordStateRecording;
        self.startPoint = [self creatPointWithLocaiton:userLocation.location title:@"起点"];
        [self.ArrayMLocaltions addObject:userLocation.location];
    }else if(_recordState == LocationRecordStateRecording){
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        // 小于5米则不画轨迹
        if (distance < 5) {
            BMK_LOG(@"距离太近放弃该点");
            return;
        }
        [self.ArrayMLocaltions addObject:userLocation.location];
        [self drawPolyline];
    }else if(_recordState == LocationRecordStateEnd){
        _recordState = LocationRecordStatePending;
//        self.endPoint = [self creatPointWithLocaiton:userLocation.location title:@"终点"];
    }
   
    self.preLocation = userLocation.location;
}

/**
 *  添加一个大头针
 *
 *  @param location 点位置
 */
- (BMKPointAnnotation *)creatPointWithLocaiton:(CLLocation *)location title:(NSString *)title;
{
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];
    
    return point;
}

/**
 *  绘制步行轨迹路线
 */
- (void)drawPolyline
{
    //轨迹点
    NSUInteger count = self.ArrayMLocaltions.count;
    
    // 手动分配存储空间，结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
    BMKMapPoint *tempPoints = new BMKMapPoint[count];
    
    [self.ArrayMLocaltions enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
//        BMK_LOG(@"idx = %ld,tempPoints X = %f Y = %f",idx,tempPoints[idx].x,tempPoints[idx].y);
    }];
    
    //移除原有的绘图
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
    }
    
    // 通过points构建BMKPolyline
    self.polyLine = [BMKPolyline polylineWithPoints:tempPoints count:count];
    
    //添加路线,绘图
    if (self.polyLine) {
        [self.mapView addOverlay:self.polyLine];
    }
    
    // 清空 tempPoints 内存
    delete []tempPoints;
    
    [self mapViewFitPolyLine:self.polyLine];
}

/**
 *  根据polyline设置地图范围
 *
 *  @param polyLine
 */
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}

/**
 *  清空数组以及地图上的轨迹
 */
- (void)cleanPolyLine
{
    //清空数组
    [self.ArrayMLocaltions removeAllObjects];
    //清屏，移除标注点
    if (self.startPoint) {
        [self.mapView removeAnnotation:self.startPoint];
        self.startPoint = nil;
    }
    if (self.endPoint) {
        [self.mapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
        self.polyLine = nil;
    }
}

#pragma mark --lazy load

- (NSMutableArray *)ArrayMLocaltions
{
    if (!_ArrayMLocaltions) {
        _ArrayMLocaltions = [NSMutableArray array];
    }
    return _ArrayMLocaltions;
}
#pragma mark --MemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
