import Cocoa

struct Alternative {
    var nameOfHistory: String
    var nameOfSickness: String
    var nameOfFeature: String
    var periodAlternatives: [PeriodOfDynamic]
}

struct Limit {
    var min: Float
    var max: Float
}

struct Moment {
    var time: Int
    var value: String
}

struct MedicalRecord {
    var name: String
    var sicknessName: String
    var features: [String: [Moment]]
}

struct PeriodOfDynamic {
    var number: Int
    var values: [String]
    var minTime: Int
    var maxTime: Int
}

struct Feature {
    let name: String
    var featureValues: [String: Bool]
    var periodsOfDynamics = [PeriodOfDynamic]()
    init(featureName _name: String, featureValues _values: [String: Bool]) {
        name = _name
        featureValues = _values
    }
}

struct Sickness {
    var name: String
    var features = [Feature]()
    init(sicknessName _name: String, classFeatures _features: [Feature]) {
        name = _name
        features = _features
    }
}

class ViewController: NSViewController {
    
    @IBOutlet var numOfSickness: NSTextField!
    @IBOutlet var numOfFeatures: NSTextField!
    @IBOutlet var numOfFeaturesValues: NSTextField!
    @IBOutlet var numOfNormalFeaturesValues: NSTextField!
    @IBOutlet var maxNumOfPeriodsOfDynamics: NSTextField!
    @IBOutlet var numOfValuesForPeriods: NSTextField!
    @IBOutlet var numOfRecords: NSTextField!
    
    @IBOutlet var comment1: NSTextField!
    @IBOutlet var comment2: NSTextField!
    @IBOutlet var comment3: NSTextField!
    @IBOutlet var comment4: NSTextField!
    @IBOutlet var comment5: NSTextField!
    @IBOutlet var comment6: NSTextField!
    @IBOutlet var comment7: NSTextField!
    @IBOutlet var evaluation: NSTextField!
    
    let maxOfClasses = 99
    let maxOfFeatures = 999
    let maxOfFeaturesValues = 999
    let maxOfPeriodsOfDynamics = 5
    let maxOfValuesForPeriods = 998
    let upperPeriodBoundary = 12
    let lowerPeriodBoundary = 11
    
    //объединение двух альтернатив с одинаковым чпд
    func combine_two_alternatives(alternative1: Alternative, alternative2: Alternative) -> Alternative? {
        
        var periods = [PeriodOfDynamic]()
        
        var previousSet = Set<String>() //множество значений предыдущего периода
        //сортировка периодов по номеру по возрастанию
        let periods1 = alternative1.periodAlternatives.sorted(by: {$0.number < $1.number})
        let periods2 = alternative2.periodAlternatives.sorted(by: {$0.number < $1.number})
        for i in 0...periods1.count - 1 {
            var values = [String]()
            var set1 = Set<String>()
            var set2 = Set<String>()
            
            for value in periods1[i].values {
                set1.insert(value)
            }
            for value in periods2[i].values {
                set2.insert(value)
            }
            
            let set = set1.union(set2)
            if set.isDisjoint(with: previousSet) { //если значения текущего периода НЕ встречаются в предыдущем периоде
                values = Array(set)
                previousSet = set
            } else { //если если значения текущего периода встречаются в предыдущем периоде, не объединять такие альтернативы
                return nil
            }
            periods.append(PeriodOfDynamic(number: i+1, values: values, minTime: min(periods1[i].minTime, periods2[i].minTime), maxTime: max(periods1[i].maxTime, periods2[i].maxTime)))
        }
        
        return Alternative(nameOfHistory: alternative1.nameOfHistory, nameOfSickness: alternative1.nameOfSickness, nameOfFeature: alternative1.nameOfFeature, periodAlternatives: periods)
    }
    
    //попарное объединение всех альтернатив с одинаковым чпд разных ИБ
    func combine_alternatives(alternatives1: [Alternative], alternatives2: [Alternative]) -> [Alternative] {
        var alternatives = [Alternative]()
        //каждая альтенатива из первого массива попарно объединяется с каждой альтернативой из новой ИБ
        for alternative1 in alternatives1 {
            for alternative2 in alternatives2 {
                let alternative = combine_two_alternatives(alternative1: alternative1, alternative2: alternative2)
                if alternative != nil { //если альтернативы возможно объединить
                    alternatives.append(alternative!) //добавление объединенных альтернатив
                }
            }
        }
        return alternatives
    }
    
    //проверка введеных параметров
    func check(_ number: Int?, _ comment: NSTextField, _ min: Int, _ max: Int) -> Bool {
        if number != nil && number! >= min && number! <= max {
            return true
        } else {
            comment.stringValue = "Некорректные данные"
            return false
        }
    }
    
    //генерация признаков: имя, ВЗ, НЗ
    func generateFeatures(numOfFeatures: Int, numOfFeaturesValues: Int, numOfNormalFeaturesValues: Int) -> [Feature] {
        var features = [Feature]()
        var values = [String: Bool]()
        var randomN: Int
        var key: String
                     
        for i in 0...numOfFeatures-1 {
            values.removeAll()
            let name = "признак" + String(i+1)
            
            //генерация значений признака
            randomN = Int.random(in: 2...numOfFeaturesValues) //генерируется случайное количество значений признака
            for j in 1...randomN {
                values["зн" + String(j)] = false
            }
            
            //генерация нормальных значений признака
            randomN = Int.random(in: 1...min(numOfNormalFeaturesValues, values.count - 1))//генерируется случайное количество нормальных признаков
            while randomN > 0 {
                key = values.keys.randomElement()!
                while values[key]! {
                    key = values.keys.randomElement()!
                }
                values[key] = true
                randomN -= 1
            }
            
            features.append(Feature(featureName: name, featureValues: values))
        }
        return features
    }
    
    //генерация периодов динамики для каждого периода
    func generatePDFeature(features: [Feature], maxNumOfPD: Int, maxNumOfValuesForPeriods: Int) -> [Feature] {
        var periodsOfDynamics = [PeriodOfDynamic]()
        var features1 = features
        
        for j in 0...features1.count-1 {
            periodsOfDynamics.removeAll()
            let randomN = Int.random(in: 1...maxNumOfPD) //генерация количества периодов для признака j
            //features1[j].periodsOfDynamics.removeAll()
            
            for k in 1...randomN { //заполнение каждого периода
                var maxTime: Int
                var minTime: Int
                var allFeatureValues = Array(features1[j].featureValues.keys) //массив возможных значений признака с индексом j
                let maxNumOfValue = min(maxNumOfValuesForPeriods, features1[j].featureValues.count - 1) //максимальное количество значений в периоде: минимальное из введенного пользователем количества и (количеством сгенерированных ВЗ для признака - 1)
                var periodValues = [String]()
                var numOfPeriodValues: Int
                
                //генерация количества значений в периоде
                if k == 1 { //для перовго периода
                    numOfPeriodValues = Int.random(in: 1...maxNumOfValue)
                } else { //для следующих периодов
                    let previousPeriodValues = Array(periodsOfDynamics[k-2].values)
                    for i in previousPeriodValues {
                        allFeatureValues = allFeatureValues.filter({$0 != i}) //фильтрация возможных
                    }
                    numOfPeriodValues = Int.random(in: 1...min(maxNumOfValue, allFeatureValues.count)) //максимальное количество значений в периоде
                }
//                } else {
//                    let previousPeriodValues = Array(periodsOfDynamics[k-2].values)
//                    let previousPeriodValues2 = Array(periodsOfDynamics[k-3].values)
//                    let previousPeriodsValues = previousPeriodValues + previousPeriodValues2
//                    if previousPeriodsValues.count < allFeatureValues.count {
//                        for i in previousPeriodsValues {
//                            allFeatureValues = allFeatureValues.filter({$0 != i}) //фильтрация возможных
//                        }
//                    } else {
//                        for i in previousPeriodValues {
//                            allFeatureValues = allFeatureValues.filter({$0 != i}) //фильтрация возможных
//                        }
//                    }
//                    numOfPeriodValues = Int.random(in: 1...min(maxNumOfValue, allFeatureValues.count)) //максимальное количество значений в периоде
//                }
                
                //заполнение периода значениями
                while numOfPeriodValues > 0 {
                    let value = allFeatureValues.randomElement()!
                    periodValues.append(value)
                    if let index = allFeatureValues.firstIndex(of: value) {
                        allFeatureValues.remove(at: index)
                    }
                    numOfPeriodValues += -1
                }
                
                maxTime = Int.random(in: 2...12)
                minTime = Int.random(in: 1...maxTime-1)
                periodsOfDynamics.insert(PeriodOfDynamic(number: k, values: periodValues, minTime: minTime, maxTime: maxTime), at: k-1)
            }
            
            for i in periodsOfDynamics {
                features1[j].periodsOfDynamics.append(i)
            }
        }
        return features1
    }
    
    @objc dynamic var table = [NPD]()
    @objc dynamic var tableKB = [KB]()
    @objc dynamic var tableMH = [MH]()
    @objc dynamic var tableNewNPD = [NewNPD]()
    @objc dynamic var tableNewKB = [NewKB]()
    
    var features = [Feature]()
    var sickness = [String: Sickness]()
    var sortedSickness: [Dictionary<String, Sickness>.Element] = []
    //[Dictionary<String, Sickness>.Element]
    @IBAction func generate(_ sender: Any) {
        tableMH = [MH]()
        table = [NPD]()
        tableKB = [KB]()
        tableNewNPD = [NewNPD]()
        tableNewKB = [NewKB]()
        comment1.stringValue = ""
        comment2.stringValue = ""
        comment3.stringValue = ""
        comment4.stringValue = ""
        comment5.stringValue = ""
        comment6.stringValue = ""
        comment7.stringValue = ""
        evaluation.stringValue = "Результаты сравнения\n"
        
        features.removeAll()
        sickness.removeAll()
        
        let _numOfSickness = Int(numOfSickness.stringValue)
        
        if check(_numOfSickness, comment1, 1, maxOfClasses) {
            let _numOfFeatures = Int(numOfFeatures.stringValue)
            if check(_numOfFeatures, comment2, 1, maxOfFeatures) {
                let _numOfFeaturesValues = Int(numOfFeaturesValues.stringValue)
                if check(_numOfFeaturesValues, comment3, 2, maxOfFeaturesValues) {
                    let _numOfNormalFeaturesValues = Int(numOfNormalFeaturesValues.stringValue)
                    if check(_numOfNormalFeaturesValues, comment4, 1, _numOfFeaturesValues! - 1) {
                        let _maxNumOfPD = Int(maxNumOfPeriodsOfDynamics.stringValue)
                        if check(_maxNumOfPD, comment5, 1, 5) {
                            let _numOfValuesForPeriods = Int(numOfValuesForPeriods.stringValue)
                            if check(_numOfValuesForPeriods, comment6, 1, _numOfFeaturesValues! - 1) {
                                
                                //генерация признаков: имя, ВЗ, НЗ (для всех заболеваний одинаковые)
                                features = generateFeatures(numOfFeatures: _numOfFeatures!, numOfFeaturesValues: _numOfFeaturesValues!, numOfNormalFeaturesValues: _numOfNormalFeaturesValues!)
                                
                                var _name: String
                                                                    
                                //генерация заболеваний
                                for i in 1..._numOfSickness! {
                                    //генерация признаков с уникальным ЧПД и ВЗ для ПД
                                    let featuresForSickness = generatePDFeature(features: features, maxNumOfPD: _maxNumOfPD!, maxNumOfValuesForPeriods: _numOfValuesForPeriods!)
                                    _name = "заболевание" + String(i)
                                    sickness[_name] = Sickness(sicknessName: _name, classFeatures: featuresForSickness)
                                }
                                 
                                //вывод
                                sortedSickness = sickness.sorted(by: {Int($0.key.dropFirst(11))! < Int($1.key.dropFirst(11))!})
                                //заболевание, признак, ВЗ, НЗ
                                for i in sortedSickness {
                                    for j in i.value.features {
                                        for k in j.featureValues {
                                            tableKB.append(KB(i.key, j.name, k.key, String(k.value)))
                                        }
                                    }
                                }
                                //заболевание, признак, период динамики, значения, НГ, ВГ
                                for i in sortedSickness {
                                    for j in i.value.features {
                                        for k in j.periodsOfDynamics {
                                            var values = ""
                                            for l in k.values {
                        //                                                    if l.value {
                        //                                                        values += l.key + "(Н) "
                        //                                                    } else {
                                                    values += l + " "
                        //                                                    }
                                            }
                                            table.append(NPD(i.key, j.name, String(j.periodsOfDynamics.count), String(k.number), values, String(k.minTime), String(k.maxTime)))
                                        }
                                        table.append(NPD("", "", "", "", "", "", ""))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var medicalRecords = [MedicalRecord]()
    
    @IBAction func generationOfMedicalRecords(_ sender: Any) {
        medicalRecords.removeAll()
        tableMH = [MH]()
        tableNewNPD = [NewNPD]()
        tableNewKB = [NewKB]()
        evaluation.stringValue = "Результаты сравнения\n"
        
        let _numOfRecords = Int(numOfRecords.stringValue)
        if check(_numOfRecords, comment7, 1, 9999) {
            //генерация историй болезней
            for currentSickness in sortedSickness {
                for record in 1..._numOfRecords! {
                    var features = [String: [Moment]]()
                    //для каждого признака из текущего заболевания генерация моментов наблюдения
                    for feature in currentSickness.value.features {
                        var featureMoments = [Moment]()
                        //сортировка периодов текущего признака по возрастанию номера периода
                        let sortedPeriods = feature.periodsOfDynamics.sorted(by:{$0.number < $1.number})
                        var periodsDuration = 0
                        //для каждого периода генерация моментов наблюдения
                        for period in sortedPeriods {
                            var duration = Int.random(in: period.minTime...period.maxTime) //генерация длительности периода
                            let newDuration = periodsDuration + duration //длительность всех прошедших периодов
                            var numOfMoments = Int.random(in: min(duration, 3)...min(duration, 7)) //генерация количества моментов наблюдения для периода
                            
                            //var numOfMoments = min(duration, 5)
                            while numOfMoments > 0 {
                                let maxRand = max(duration - numOfMoments, 1) //максмально возможное время момента наблюдения <= длительность ПД - количество моментов наблюдения
                                let time = Int.random(in: 1...maxRand) //время момента наблюдения
                                duration +=  -time //вычисление оставшейся длительности после момента
                                periodsDuration += time //время от начала
                                let value = period.values.randomElement()
                                //let value = String(period.values[Int.random(in: 0...period.values.count-1)]) //генерация значения МН
                                featureMoments.append(Moment(time: periodsDuration, value: value!))
                                numOfMoments += -1
                            }
                            periodsDuration = newDuration
                        }
                        features[feature.name] = featureMoments
                    }
                    medicalRecords.append(MedicalRecord(name: "ИБ" + String(record), sicknessName: currentSickness.key, features: features))
                }
            }
            
            //вывод
            for record in medicalRecords {
                let features = record.features.sorted(by: {Int($0.key.dropFirst(7))! < Int($1.key.dropFirst(7))!})
                for feature in features {
                    let sortedMoments = feature.value.sorted(by: {$0.time < $1.time})
                    for moment in sortedMoments {
                        tableMH.append(MH(record.sicknessName, record.name, feature.key, moment.value, String(moment.time)))
                    }
                }
            }
        }
    }
    
    
    @IBAction func knowleddgeBaseRestoration(_ sender: Any) {
        tableNewNPD = [NewNPD]()
        tableNewKB = [NewKB]()
        evaluation.stringValue = "Результаты сравнения\n"
          
        //восстановление базы знаний
        var periodAlternatives = [Alternative]()
        for record in medicalRecords {
            for feature in record.features {
                let moments = feature.value.sorted(by: {$0.time < $1.time}) //сортировка всех моментов текущего признака по возрастанию времени
                var limits = [[Limit]]()
                var limit = [Limit(min: 0, max: Float(moments[moments.count-1].time + 1))] //границы для одного периода
                limits.append(limit)
                limit.removeAll()
                //расстановка границ
                if moments.count > 1 { //если можно разедить на два периода
                    for i in 0...moments.count - 2 { //от первого до предпоследнего
                        var setFirstPeriodValues = Set<String>()
                        for index in 0...i {
                            setFirstPeriodValues.insert(moments[index].value)
                        }
                        var setSecondPeriodValues = Set<String>()
                        for index in i + 1...moments.count - 1 {
                            setSecondPeriodValues.insert(moments[index].value)
                        }
                        if setFirstPeriodValues.isDisjoint(with: setSecondPeriodValues){
                            limit.append(Limit(min: 0, max: Float(Float(moments[i].time + moments[i + 1].time) / 2.0))) // границы первого периода
                            limit.append(Limit(min: Float(Float(moments[i].time + moments[i + 1].time) / 2.0), max: Float(moments[moments.count-1].time + 1))) //границы второго периода
                            limits.append(limit)
                            limit.removeAll()
                        }
                    }
                    if moments.count > 2 { //если можно разделить на три периода
                        for i in 0...moments.count - 3 { // от первого до (последнего - 2)
                            for j in (i + 1)...moments.count - 2 {
                                var setFirstPeriodValues = Set<String>()
                                for index in 0...i {
                                    setFirstPeriodValues.insert(moments[index].value)
                                }
                                var setSecondPeriodValues = Set<String>()
                                for index in i + 1...j {
                                    setSecondPeriodValues.insert(moments[index].value)
                                }
                                var setThirdPeriodValues = Set<String>()
                                for index in j + 1...moments.count - 1 {
                                    setThirdPeriodValues.insert(moments[index].value)
                                }
                                //если множества значений соседних периодов не пересекаются, расставить границы
                                if setFirstPeriodValues.isDisjoint(with: setSecondPeriodValues) && setSecondPeriodValues.isDisjoint(with: setThirdPeriodValues) {
                                
                                    limit.append(Limit(min: 0, max: Float(Float(moments[i].time + moments[i + 1].time) / 2))) // границы первого периода
                                    limit.append(Limit(min: Float(Float(moments[i].time + moments[i + 1].time) / 2), max: Float(Float(moments[j].time + moments[j + 1].time) / 2))) // границы второго периода
                                    limit.append(Limit(min: Float(Float(moments[j].time + moments[j + 1].time) / 2), max: Float(moments[moments.count-1].time + 1))) // границы третьего периода
                                    limits.append(limit)
                                    limit.removeAll()
                                }
                            }
                        }
                        if moments.count > 3 { //если можно разделить на четыре периода
                            for i in 0...moments.count - 4 {
                                for j in (i + 1)...moments.count - 3 {
                                    for k in (j + 1)...moments.count - 2 {
                                        var setFirstPeriodValues = Set<String>()
                                        for index in 0...i {
                                            setFirstPeriodValues.insert(moments[index].value)
                                        }
                                        var setSecondPeriodValues = Set<String>()
                                        for index in i + 1...j {
                                            setSecondPeriodValues.insert(moments[index].value)
                                        }
                                        var setThirdPeriodValues = Set<String>()
                                        for index in j + 1...k {
                                            setThirdPeriodValues.insert(moments[index].value)
                                        }
                                        var setFourthPeriodValues = Set<String>()
                                        for index in k + 1...moments.count - 1 {
                                            setFourthPeriodValues.insert(moments[index].value)
                                        }
                                        
                                        if setFirstPeriodValues.isDisjoint(with: setSecondPeriodValues) && setSecondPeriodValues.isDisjoint(with: setThirdPeriodValues) && setThirdPeriodValues.isDisjoint(with: setFourthPeriodValues) {
                                            limit.append(Limit(min: 0, max: Float(Float(moments[i].time + moments[i + 1].time) / 2))) // границы первого периода
                                            limit.append(Limit(min: Float(Float(moments[i].time + moments[i + 1].time) / 2), max: Float(Float(moments[j].time + moments[j + 1].time) / 2))) // границы второго периода
                                            limit.append(Limit(min: Float(Float(moments[j].time + moments[j + 1].time) / 2), max: Float(Float(moments[k].time + moments[k + 1].time) / 2))) // границы третьего периода
                                            limit.append(Limit(min: Float(Float(moments[k].time + moments[k + 1].time) / 2), max: Float(moments[moments.count-1].time + 1))) // границы четвертого периода
                                            limits.append(limit)
                                            limit.removeAll()
                                        }
                                    }
                                }
                            }
                            if moments.count > 4 {
                                for i in 0...moments.count - 5 {
                                    for j in (i + 1)...moments.count - 4 {
                                        for k in (j + 1)...moments.count - 3 {
                                            for l in (k + 1)...moments.count - 2 {
                                                var setFirstPeriodValues = Set<String>()
                                                for index in 0...i {
                                                    setFirstPeriodValues.insert(moments[index].value)
                                                }
                                                var setSecondPeriodValues = Set<String>()
                                                for index in i + 1...j {
                                                    setSecondPeriodValues.insert(moments[index].value)
                                                }
                                                var setThirdPeriodValues = Set<String>()
                                                for index in j + 1...k {
                                                    setThirdPeriodValues.insert(moments[index].value)
                                                }
                                                var setFourthPeriodValues = Set<String>()
                                                for index in k + 1...l {
                                                    setFourthPeriodValues.insert(moments[index].value)
                                                }
                                                var setFifthPeriodValues = Set<String>()
                                                for index in l + 1...moments.count - 1 {
                                                    setFifthPeriodValues.insert(moments[index].value)
                                                }
                                                
                                                if setFirstPeriodValues.isDisjoint(with: setSecondPeriodValues) && setSecondPeriodValues.isDisjoint(with: setThirdPeriodValues) && setThirdPeriodValues.isDisjoint(with: setFourthPeriodValues) && setFourthPeriodValues.isDisjoint(with: setFifthPeriodValues) {
                                                    limit.append(Limit(min: 0, max: Float(Float(moments[i].time + moments[i + 1].time) / 2))) // границы первого периода
                                                    limit.append(Limit(min: Float(Float(moments[i].time + moments[i + 1].time) / 2), max: Float(Float(moments[j].time + moments[j + 1].time) / 2))) // границы второго периода
                                                    limit.append(Limit(min: Float(Float(moments[j].time + moments[j + 1].time) / 2), max: Float(Float(moments[k].time + moments[k + 1].time) / 2))) // границы третьего периода
                                                    limit.append(Limit(min: Float(Float(moments[k].time + moments[k + 1].time) / 2), max: Float(Float(moments[l].time + moments[l + 1].time) / 2))) // границы четвертого периода
                                                    limit.append(Limit(min: Float(Float(moments[l].time + moments[l + 1].time) / 2), max: Float(moments[moments.count-1].time + 1))) // границы пятого периода
                                                    limits.append(limit)
                                                    limit.removeAll()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                //создание альтернатив
                for arrayOfLimits in limits { //для всех вариантов расстановок границ [(НГ, ВГ)]
                    var periodIndex = 1
                    var periodOfDynamic = [PeriodOfDynamic]()
                    
                    for periodLimit in arrayOfLimits { //для всех пар (НГ, ВГ)
                        var periodValues = [String]()
                        var minTime = 1
                        var maxTime = 1
                        //проверяются все моменты текущего признака
                        for moment in moments {
                            if Float(moment.time) > periodLimit.min && Float(moment.time) < periodLimit.max { //если момент попадает в границы, добавить его
                                periodValues.append(moment.value)
                                if minTime < moment.time - Int(floor(periodLimit.min)) {
                                    minTime = moment.time - Int(floor(periodLimit.min)) //нижняя гарница
                                }
                                if maxTime < moment.time - Int(floor(periodLimit.min)) {
                                    maxTime = moment.time - Int(floor(periodLimit.min)) //верхнаяя граница
                                }
                            }
                        }
                        periodOfDynamic.append(PeriodOfDynamic(number: periodIndex, values: periodValues, minTime: minTime, maxTime: maxTime))
                        periodIndex += 1
                        
                    }
                    periodAlternatives.append(Alternative(nameOfHistory:record.name, nameOfSickness: record.sicknessName, nameOfFeature: feature.key, periodAlternatives: periodOfDynamic))
                }
            }
        }
        
        var newSickness = [String: Sickness]()
        
        for currentSickness in sickness { //для каждого заболевания
            var newFeatures = [Feature]()
            for feature in currentSickness.value.features { //для каждого признака
                var alternativeForFeature = [String: [Alternative]]()
                //выделяем все альтернативы для конкретного признака конкретного заболевания, сохраняя имя ИБ, чтобы различать
                var maxNPD = 1
                for alterantive in periodAlternatives {
                    if alterantive.nameOfSickness == currentSickness.key && alterantive.nameOfFeature == feature.name {
                        if alterantive.periodAlternatives.count > maxNPD {
                            maxNPD = alterantive.periodAlternatives.count
                        }
                        if alternativeForFeature[alterantive.nameOfHistory] == nil {
                            alternativeForFeature[alterantive.nameOfHistory] = [alterantive]
                        } else {
                            alternativeForFeature[alterantive.nameOfHistory]!.append(alterantive)
                        }
                    }
                }
                
                var newAlternativeNPD = [[Alternative]]()
                
                for npd in 1...maxNPD {
                    //отбираем все альтернативы с таким числом периодов динамики
                    //сохраняем название истории, чтобы отличать альтернативы
                    //альтеранатива с максимальным чпд добавится последней в конец
                    var alternativeNPD = [String: [Alternative]]() //один элемент - массив альтернатив с одинаковым ЧПД=npd одинаковой истории болезни для одного признака
                    
                    for alternativeHistory in alternativeForFeature {
                        for alternative in alternativeHistory.value {
                            if alternative.periodAlternatives.count == npd {
                                if alternativeNPD[alternative.nameOfHistory] == nil {
                                    alternativeNPD[alternative.nameOfHistory] = [alternative]
                                } else {
                                    alternativeNPD[alternative.nameOfHistory]!.append(alternative)
                                }
                            }
                        }
                    }
                    
                    //объединяем альтернативы одного признака из разных историй с одинаковым ЧПД=npd
                    let historyNames = Array(alternativeNPD.keys) //массив названий всех иб
                    let numOfHistoryForFeature = alternativeForFeature.count
                    //если во всех иб с этим признаком есть альтернативы с таким чпд, объединияем их
                    if alternativeNPD.count == numOfHistoryForFeature {
                        newAlternativeNPD.append(alternativeNPD[historyNames[0]]!) //элемент - массив всех возможных объединений альтернатив всех иб с одинаковым чпд
                        if alternativeNPD.count > 1 {
                            for index in 1...historyNames.count - 1 {
                                let alternatives = combine_alternatives(alternatives1: newAlternativeNPD[newAlternativeNPD.count-1], alternatives2: alternativeNPD[historyNames[index]]!)
                                if alternatives.isEmpty { //если нельзя объединить альтернативы с таким чпд, не добавлять в массив новых альтернатив
                                    newAlternativeNPD.remove(at: newAlternativeNPD.count-1)
                                    break
                                } else {
                                    newAlternativeNPD[newAlternativeNPD.count-1] = alternatives
                                }
                            }
                        }
                    }
                }
                
                //вывод всех альтернатив
//                                            for alternative in newAlternativeNPD {
//                                                for _alternative in alternative {
//                                                    for period in _alternative.periodAlternatives {
//                                                        var values = ""
//                                                        for value in period.values {
//                                                            values += value + " "
//                                                        }
//                                                        tableNewNPD.append(NewNPD(_alternative.nameOfSickness, _alternative.nameOfFeature, String(_alternative.periodAlternatives.count), String(period.number), values, String(period.minTime), String(period.maxTime)))
//                                                    }
//                                                    tableNewNPD.append(NewNPD("", "", "", "", "", "", ""))
//                                                }
//                                            }
                
                //конечный вариант - последняя альтернатива (с максимальным ЧПД)
                let newAlternative = newAlternativeNPD[newAlternativeNPD.count - 1][0]
                
                var newValues = [String: Bool]() //все возможные значения признака
                for period in newAlternative.periodAlternatives {
                    for value in period.values {
                        newValues[value] = false
                    }
                }
                newFeatures.append(Feature(featureName: feature.name, featureValues: newValues))
                newFeatures[newFeatures.count - 1].periodsOfDynamics = newAlternative.periodAlternatives
            }
            newSickness[currentSickness.key] = Sickness(sicknessName: currentSickness.key, classFeatures: newFeatures)
        }
        
        //сортировка периодов динамики и признаков
        for i in newSickness.keys {
            for j in 0...newSickness[i]!.features.count-1 {
                newSickness[i]!.features[j].periodsOfDynamics = newSickness[i]!.features[j].periodsOfDynamics.sorted(by: {$0.number < $1.number})
            }
            newSickness[i]!.features = newSickness[i]!.features.sorted(by:{Int($0.name.dropFirst(7))! < Int($1.name.dropFirst(7))!})
        }
        let sortedNewSickness = newSickness.sorted(by: {Int($0.key.dropFirst(11))! < Int($1.key.dropFirst(11))!})
        
        medicalRecords = medicalRecords.sorted(by: {Int($0.sicknessName.dropFirst(11))! < Int($1.sicknessName.dropFirst(11))!})
        
        
        //сравнение ЧПД
    
        var sumNPDMatchPercentages = 0.0
        var sumIdenticalMatchPercentage = 0.0
        var sumSubsetPercentage1 = 0.0
        var sumSubsetPercentage2 = 0.0
        var sumErrorPercentage = 0.0
        //var sumNumOfNPD = 0.0
        
        for sicknessIndex in 0...sortedSickness.count - 1 {
            var numOfMatchedNPD = 0.0
            var numOfNPD = 0.0
            var identicalMatchPercentage = 0.0
            var subsetPercentage1 = 0.0
            var subsetPercentage2 = 0.0
            var errorPercentage = 0.0
            var NPDMatchPercentages = 0.0
            
            for featuresIndex in 0...sortedSickness[sicknessIndex].value.features.count - 1 {
                if sortedSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics.count == sortedNewSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics.count {
                    numOfMatchedNPD += 1.0
                    numOfNPD += Double(sortedNewSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics.count)
                    //sumNumOfNPD += numOfNPD
                    
                    for periodIndex in 0...sortedSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics.count - 1 {
                        if Set(sortedSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values) == Set(sortedNewSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values) {
                            identicalMatchPercentage += 1.0
                        } else if Set(sortedSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values).isSuperset(of: Set(sortedNewSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values)) {
                            subsetPercentage1 += 1.0
                        } else if Set(sortedSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values).isSubset(of: Set(sortedNewSickness[sicknessIndex].value.features[featuresIndex].periodsOfDynamics[periodIndex].values)) {
                            subsetPercentage2 += 1.0
                        } else {
                            errorPercentage += 1.0
                        }
                    }
                }
            }
            
            NPDMatchPercentages = Double(numOfMatchedNPD / Double(sortedSickness[sicknessIndex].value.features.count)) //процент совпадения ЧПД
            sumNPDMatchPercentages += NPDMatchPercentages
            sumIdenticalMatchPercentage += round(identicalMatchPercentage / numOfNPD * 1000) / 10
            sumSubsetPercentage1 += round(subsetPercentage1 / numOfNPD * 1000)/10
            sumSubsetPercentage2 += round(subsetPercentage2 / numOfNPD * 1000)/10
            sumErrorPercentage += round(errorPercentage / numOfNPD * 1000)/10
            
            evaluation.stringValue += "\n" + sortedSickness[sicknessIndex].key + ": \n"
            evaluation.stringValue += "Процент совпадения ЧПД: " + String(round(NPDMatchPercentages * 1000)/10) + "%\n"
            evaluation.stringValue += "ЗДП(МБЗ) ≡ ЗДП(ИФБЗ): " + String(round(identicalMatchPercentage / numOfNPD * 1000) / 10) + "%\n"
            evaluation.stringValue += "ЗДП(МБЗ) ⊂ ЗДП(ИФБЗ): " + String(round(subsetPercentage1 / numOfNPD * 1000)/10) + "%\n"
            evaluation.stringValue += "ЗДП(ИФБЗ) ⊂ ЗДП(МБЗ): " + String(round(subsetPercentage2 / numOfNPD * 1000)/10) + "%\n"
            evaluation.stringValue += "ЗДП(МБЗ) ≠ ЗДП(ИФБЗ): " + String(round(errorPercentage / numOfNPD * 1000)/10) + "%\n"
            
        }
        
        //средний процент совпадений ЧПД у одноименных признаков - для всех заболеваний
        
        evaluation.stringValue += "\nСредний процент совпадения ЧПД: " + String(round(sumNPDMatchPercentages / Double(sickness.count) * 1000) / 10) + "% \n"
        evaluation.stringValue += "\nСредний процент ЗДП(МБЗ) ≡ ЗДП(ИФБЗ): " + String(round(sumIdenticalMatchPercentage / Double(sickness.count) * 10) / 10) + "%\n"
        evaluation.stringValue += "\nСредний процент ЗДП(МБЗ) ⊂ ЗДП(ИФБЗ): " + String(round(sumSubsetPercentage1 / Double(sickness.count) * 10) / 10) + "%\n"
        evaluation.stringValue += "\nСредний процент ЗДП(ИФБЗ) ⊂ ЗДП(МБЗ): " + String(round(sumSubsetPercentage2 / Double(sickness.count) * 10) / 10) + "%\n"
        evaluation.stringValue += "\nСредний процент ЗДП(МБЗ) ≠ ЗДП(ИФБЗ): " + String(round(sumErrorPercentage / Double(sickness.count) * 10) / 10) + "%\n"
        
        //вывод ИБЗ
        for i in sortedNewSickness {
            for j in i.value.features {
                for k in j.featureValues {
                    tableNewKB.append(NewKB(i.key, j.name, k.key))
                }
            }
        }

        for i in sortedNewSickness {
            for j in i.value.features {
                for k in j.periodsOfDynamics {
                    var values = ""
                    for l in k.values {
                        values += l + " "
                    }
                    tableNewNPD.append(NewNPD(i.key, j.name, String(j.periodsOfDynamics.count), String(k.number), values, String(k.minTime), String(k.maxTime)))
                }
                tableNewNPD.append(NewNPD("", "", "", "", "", "", ""))
            }
        }
    }
}
